module Api
  class UserChallengesController < ApplicationController
    before_action :authenticate_api_user!
    before_action :ensure_weekly_window!
    before_action :set_weekly

    def index
      @list = current_user.user_challenges
                          .includes(:challenge)
                          .where(weekly_progress: @weekly)
                          .order(created_at: :asc)
      render :index
    end

    def update
      @user_challenge = UserChallenges::Update.call(
        user:   current_user,
        weekly: @weekly,
        id:     params[:id],
        params: update_params.to_h.symbolize_keys
      )
      render :update
    rescue UserChallenges::Update::ValidationFailed => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue UserChallenges::Update::NotFound
      render json: { error: "UserChallenge not found" }, status: :not_found
    end

    def create
      created_count = UserChallenges::Create.call(
        user: current_user,
        weekly: @weekly,
        diagnosis_result_id: params.require(:diagnosis_result_id),
        challenge_ids: params.require(:challenge_ids),
        focus_trait_code: params[:focus_trait_code]
      )

      head(created_count.zero? ? :no_content : :created)
    rescue UserChallenges::Create::ValidationFailed => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def set_weekly
      @weekly = guess_current_week_for(current_user) || resolve_current_week_for(current_user)
    end

    def update_params
      params.require(:user_challenge)
            .permit(:status, :exec_count, :comment, emotion_tag_ids: [])
    end
  end
end
