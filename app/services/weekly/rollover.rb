
# frozen_string_literal: true
module Weekly
  class Rollover
    # Public: Ensure weekly window for all users and close past weeks.
    #
    # This will:
    # 1) For every user who has at least one WeeklyProgress (anchor),
    #    ensure the current week's WeeklyProgress exists (idempotent).
    # 2) For all prior weeks for that user, mark any in-flight UserChallenges
    #    as expired (status: :expired).
    #
    # NOTE: This service does NOT create DiagnosisResult or assign challenges for the new week.
    #       Those are handled by existing controllers/UI flows.
    #
    # Options:
    # - today: Date (defaults to Time.zone.today)
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
      return unless anchor # user hasn't started program yet

      current_start_at = compute_start_at(anchor, today)
      last_week        = user.weekly_progresses.order(:week_no).last

      ActiveRecord::Base.transaction do
        # 1) Create current week if missing
        weekly = user.weekly_progresses.find_by(start_at: current_start_at)
        unless weekly
          next_week_no = (last_week&.week_no || 0) + ((current_start_at > (last_week&.start_at || anchor)) ? 1 : 0)
          # Safety: if multiple weeks were skipped without login, fill only the current boundary
          weekly = user.weekly_progresses.create!(
            week_no:  next_week_no,
            start_at: current_start_at
          )
        end

        # 2) Close/expire past weeks' unfinished challenges
        expire_past_user_challenges(user, before_start_at: current_start_at)
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("[Weekly::Rollover] user=#{user.id} #{e.record.errors.full_messages.to_sentence}")
    rescue => e
      Rails.logger.error("[Weekly::Rollover] user=#{user.id} #{e.class}: #{e.message}")
    end

    # Given an anchor date (first WeeklyProgress.start_at) and 'today', compute the
    # start_at for the user's current week window.
    def compute_start_at(anchor, today)
      days = (today - anchor).to_i
      weeks_since = days / 7
      anchor + weeks_since * 7
    end

    def expire_past_user_challenges(user, before_start_at:)
      past_week_ids = user.weekly_progresses.where("start_at < ?", before_start_at).pluck(:id)
      return if past_week_ids.empty?

      # Only unstarted/executing should be expired
      user.user_challenges
          .where(weekly_progress_id: past_week_ids, status: [:unstarted, :executing])
          .update_all(status: UserChallenge.statuses[:expired], updated_at: Time.current)
    end
  end
end
