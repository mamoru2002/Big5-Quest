# frozen_string_literal: true

# 全ユーザー分の WeeklyProgress を進めて、過去週の未完了チャレンジを expired にする
module Weekly
  class Rollover
    def self.call(today: nil)
      new(today: today || Time.zone.today).call
    end

    def initialize(today: Time.zone.today)
      @today = today
    end

    def call
      User.find_each do |user|
        ensure_for_user(user)
      end
    end

    private

    attr_reader :today

    def ensure_for_user(user)
      anchor = user.weekly_progresses.minimum(:start_at)&.to_date
      return unless anchor

      current_start_at = compute_start_at(anchor, today)
      last_week        = user.weekly_progresses.order(:week_no).last

      ActiveRecord::Base.transaction do
        weekly = user.weekly_progresses.find_by(start_at: current_start_at)
        unless weekly
          next_week_no = (last_week&.week_no || 0) + ((current_start_at > (last_week&.start_at || anchor)) ? 1 : 0)
          weekly = user.weekly_progresses.create!(
            week_no:  next_week_no,
            start_at: current_start_at
          )
        end

        expire_past_user_challenges(user, before_start_at: current_start_at)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("[Weekly::Rollover] user=#{user.id} #{e.record.errors.full_messages.to_sentence}")
    rescue => e
      Rails.logger.error("[Weekly::Rollover] user=#{user.id} #{e.class}: #{e.message}")
    end

    def compute_start_at(anchor, today)
      days = (today - anchor).to_i
      weeks_since = days / 7
      anchor + weeks_since * 7
    end

    def expire_past_user_challenges(user, before_start_at:)
      past_week_ids = user.weekly_progresses.where("start_at < ?", before_start_at).pluck(:id)
      return if past_week_ids.empty?

      user.user_challenges
          .where(weekly_progress_id: past_week_ids, status: [ :unstarted, :executing ])
          .update_all(status: UserChallenge.statuses[:expired], updated_at: Time.current)
    end
  end
end
