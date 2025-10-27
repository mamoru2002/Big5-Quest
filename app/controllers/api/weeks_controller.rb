module Api
  class WeeksController < ApplicationController
    before_action :authenticate_api_user!
    before_action :ensure_weekly_window!
    def current
      @weekly   = resolve_current_week_for(current_user)
      @editable = true
      preload_week_data(@weekly)
      render :show
    end

    def show
      base     = guess_current_week_for(current_user) || resolve_current_week_for(current_user)
      offset   = params[:offset].to_i
      start_at = base.start_at + offset * 7

      @weekly = current_user.weekly_progresses.find_by(start_at: start_at)
      return render json: { error: "week not found" }, status: :not_found if @weekly.nil?

      @editable = (@weekly.start_at == (guess_current_week_for(current_user)&.start_at || base.start_at))
      preload_week_data(@weekly)
      render :show
    end

    private

    def preload_week_data(weekly)
      @list = current_user.user_challenges
                          .includes(:challenge)
                          .where(weekly_progress: weekly)
                          .order(created_at: :asc)

      latest_result = current_user.diagnosis_results
                                   .where(weekly_progress: weekly)
                                   .order(created_at: :desc)
                                   .limit(1)
                                   .first

      @result_id         = latest_result&.id
      @diagnosis_status  = latest_result&.status
      @paused_this_week  = weekly.weekly_pauses.exists?
    end
  end
end
