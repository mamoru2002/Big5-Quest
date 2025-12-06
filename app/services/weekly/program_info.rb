# frozen_string_literal: true

# 各ユーザーの週次進行状況から「何週目か」「マイルストーンか」「A/B/Cローテーションか」を判定する
module Weekly
  class ProgramInfo
    TOTAL_WEEKS = 15
    FINAL_WEEK_INDEX = TOTAL_WEEKS - 1
    ROTATION_LETTERS = %w[A B C].freeze
    MILESTONE_CYCLE = %w[A B].freeze

    attr_reader :user, :weekly

    def initialize(user:, weekly:)
      @user = user
      @weekly = weekly
    end

    def program_week
      (weekly.week_no || 1) - 1
    end

    def final_week?
      return false unless FINAL_WEEK_INDEX

      program_week >= FINAL_WEEK_INDEX
    end

    def milestone_week?
      return false unless program_week.positive?
      return false if final_week?

      (program_week % 5).zero?
    end

    def milestone_bucket
      return nil unless milestone_week?

      cycle_index = (program_week / 5) - 1
      MILESTONE_CYCLE[cycle_index % MILESTONE_CYCLE.size]
    end

    def rotation_bucket
      return nil if final_week? || milestone_week? || paused_week? || program_week.zero?

      index = prior_active_week_count % ROTATION_LETTERS.size
      ROTATION_LETTERS[index]
    end

    def paused_week?
      weekly.weekly_pauses.loaded? ? weekly.weekly_pauses.any? : weekly.weekly_pauses.exists?
    end

    def focus_trait_code
      @focus_trait_code ||= begin
        from_challenges = latest_challenge_trait_code
        return from_challenges if from_challenges

        latest_diagnosis_trait_code
      end&.upcase
    end

    private

    def prior_active_week_count
      @prior_active_week_count ||= begin
        previous_weeks = user.weekly_progresses
                              .where("week_no < ?", weekly.week_no)
                              .includes(:weekly_pauses)

        previous_weeks.count do |wp|
          previous_program_week = (wp.week_no || 1) - 1
          paused = wp.weekly_pauses.loaded? ? wp.weekly_pauses.any? : wp.weekly_pauses.exists?
          final = FINAL_WEEK_INDEX && previous_program_week >= FINAL_WEEK_INDEX
          milestone = previous_program_week.positive? && (previous_program_week % 5).zero? && !final

          previous_program_week.positive? && !paused && !milestone && !final
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
