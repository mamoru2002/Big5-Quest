# frozen_string_literal: true

module Weekly
  class ProgramInfo
    TOTAL_WEEKS      = 15
    FINAL_WEEK_INDEX = TOTAL_WEEKS - 1

    ROTATION_LETTERS = %w[A B C].freeze
    MILESTONE_CYCLE  = %w[A B].freeze

    attr_reader :user, :weekly

    def initialize(user:, weekly:)
      @user   = user
      @weekly = weekly
    end

    # 0-based（1週目=0, 5週目=4, 10週目=9, 15週目=14）
    def program_week
      return fallback_program_week unless program_start_at

      weeks_since = ((weekly.start_at.to_date - program_start_at).to_i) / 7
      [ weeks_since, 0 ].max
    end

    def final_week?
      program_week >= FINAL_WEEK_INDEX
    end

    # 5週目/10週目（= program_week 4 / 9）
    def milestone_week?
      return false if program_week.zero?
      return false if final_week?

      ((program_week + 1) % 5).zero?
    end

    def milestone_bucket
      return nil unless milestone_week?

      milestone_number = (program_week + 1) / 5 # 5週目=>1, 10週目=>2
      MILESTONE_CYCLE[(milestone_number - 1) % MILESTONE_CYCLE.size]
    end

    def rotation_bucket
      return nil if final_week? || milestone_week? || paused_week? || program_week.zero?

      index = prior_active_week_count % ROTATION_LETTERS.size
      ROTATION_LETTERS[index]
    end

    def paused_week?
      weekly.weekly_pauses.loaded? ? weekly.weekly_pauses.any? : weekly.weekly_pauses.exists?
    end

    # ★ここが重要：program があるならそれを最優先
    def focus_trait_code
      @focus_trait_code ||= begin
        from_program = active_program&.focus_trait_code
        return from_program if from_program.present?

        from_challenges = latest_challenge_trait_code
        return from_challenges if from_challenges.present?

        latest_diagnosis_trait_code
      end&.to_s&.upcase
    end

    private

    def active_program
      @active_program ||= user.active_user_program
    end

    def program_start_at
      @program_start_at ||= active_program&.start_at&.to_date
    end

    def fallback_program_week
      (weekly.week_no || 1) - 1
    end

    # 「ローテ対象になった過去週」の数（プログラム開始日基準）
    def prior_active_week_count
      @prior_active_week_count ||= begin
        return 0 unless program_start_at

        previous_weeks = user.weekly_progresses
                             .where("start_at >= ? AND start_at < ?", program_start_at, weekly.start_at)
                             .includes(:weekly_pauses)
                             .order(:start_at)

        previous_weeks.count do |wp|
          rel_week = ((wp.start_at.to_date - program_start_at).to_i) / 7

          paused = wp.weekly_pauses.loaded? ? wp.weekly_pauses.any? : wp.weekly_pauses.exists?
          final  = rel_week >= FINAL_WEEK_INDEX
          milestone = rel_week.positive? && !final && ((rel_week + 1) % 5).zero?

          rel_week.positive? && !paused && !milestone && !final
        end
      end
    end

    def latest_challenge_trait_code
      user.user_challenges
          .joins(challenge: :trait)
          .order("user_challenges.created_at DESC")
          .limit(1)
          .pluck("traits.code")
          .first
    end

    def latest_diagnosis_trait_code
      names = user.diagnosis_results
                  .joins(:diagnosis_form)
                  .order("diagnosis_results.created_at DESC")
                  .pluck("diagnosis_forms.name")

      names.each do |name|
        trait = extract_trait_from_form_name(name)
        return trait if trait
      end

      nil
    end

    def extract_trait_from_form_name(name)
      return nil unless name

      name.to_s.match(/_(e|c|n)(?:_|$)/)&.captures&.first&.upcase
    end
  end
end
