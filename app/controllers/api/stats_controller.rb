module Api
  class StatsController < ApplicationController
    before_action :require_user!

    def summary
      uid = current_user.id

      total_completed = UserChallenge.where(user_id: uid)
                                     .where.not(first_done_at: nil)
                                     .count

      total_exec = UserChallenge.where(user_id: uid).sum(:exec_count)

      total_weeks_with_any_completion = UserChallenge.where(user_id: uid)
                                                     .where.not(first_done_at: nil)
                                                     .distinct
                                                     .count(:weekly_progress_id)

      render json: {
        total_completed: total_completed,
        total_exec: total_exec,
        total_weeks_with_any_completion: total_weeks_with_any_completion
      }
    end

    def trait_history
      code = params[:code].to_s.upcase
      trait = Trait.find_by(code: code)
      return render json: { error: 'invalid_trait' }, status: :bad_request unless trait

      uid = current_user.id

      rows = DiagnosisResult
               .joins(:weekly_progress)
               .joins(responses: :question)
               .where(user_id: uid)
               .where(questions: { trait_id: trait.id })
               .group('weekly_progresses.week_no')
               .select(<<~SQL.squish)
                 weekly_progresses.week_no AS week_no,
                 SUM(
                   CASE WHEN questions.reverse_scored
                        THEN (6 - responses.value)
                        ELSE responses.value
                   END
                 ) AS trait_score
               SQL
               .order('weekly_progresses.week_no ASC')

      points = rows.map { |r| { week: r.week_no.to_i, score: r.trait_score.to_i } }
      base = points.first&.[](:score)
      if base
        points.each { |p| p[:delta] = p[:score] - base }
      else
        points = []
      end

      render json: { points: points }
    end

    private

    def require_user!
      head :unauthorized unless current_user
    end
  end
end