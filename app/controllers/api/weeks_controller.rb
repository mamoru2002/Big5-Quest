# app/controllers/api/weeks_controller.rb
module Api
  class WeeksController < ApplicationController
    def current
      weekly = resolve_current_week_for(current_user)
      render_week(weekly, editable: true)
    end

    def show
      base    = guess_current_week_for(current_user) || resolve_current_week_for(current_user)
      offset  = params[:offset].to_i
      start_at = base.start_at + offset * 7

      weekly = current_user.weekly_progresses.find_by(start_at: start_at)
      return render json: { error: "week not found" }, status: :not_found if weekly.nil?

      editable = (weekly.start_at == (guess_current_week_for(current_user)&.start_at || base.start_at))
      render_week(weekly, editable: editable)
    end

    private

    def render_week(weekly, editable:)
      list = current_user.user_challenges
                         .includes(:challenge)
                         .where(weekly_progress: weekly)
                         .order(created_at: :asc)

      challenges = list.map { |uc|
        {
          id:         uc.id,
          status:     uc.status,
          exec_count: uc.exec_count,
          challenge: {
            id:         uc.challenge_id,
            title:      uc.challenge.title,
            difficulty: uc.challenge.difficulty
          }
        }
      }

      result_id = current_user.diagnosis_results
                              .where(weekly_progress: weekly)
                              .order(created_at: :desc)
                              .limit(1)
                              .pluck(:id)
                              .first

      render json: {
        week_no:   weekly.week_no,
        start_at:  weekly.start_at,
        end_at:    weekly.start_at + 6,
        editable:  editable,
        result_id: result_id,
        challenges: challenges
      }
    end
  end
end
