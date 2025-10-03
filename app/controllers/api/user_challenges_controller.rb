module Api
  class UserChallengesController < ApplicationController
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
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def create
      ids = Array(params.require(:challenge_ids))
      unless ids.length.between?(1, 4)
        return render json: { error: "1〜4件選んでください" }, status: :unprocessable_entity
      end

      result = current_user.diagnosis_results.find(params[:diagnosis_result_id])
      weekly = result.weekly_progress

      existing = current_user.user_challenges
                             .where(weekly_progress: weekly, challenge_id: ids)
                             .pluck(:challenge_id)
      new_ids = ids.map(&:to_i) - existing
      return head :no_content if new_ids.empty?

      UserChallenge.transaction do
        new_ids.each do |c_id|
          UserChallenge.create!(
            user:            current_user,
            challenge_id:    c_id,
            weekly_progress: weekly,
            status:          :unstarted,
            exec_count:      0
          )
        end
      end

      head :created
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
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
