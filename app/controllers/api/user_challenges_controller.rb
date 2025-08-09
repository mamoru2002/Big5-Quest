# app/controllers/api/user_challenges_controller.rb
module Api
  class UserChallengesController < ApplicationController
    before_action :set_weekly

    # GET /api/user_challenges
    def index
      list = current_user.user_challenges
                         .includes(:challenge)
                         .where(weekly_progress: @weekly)
                         .order(created_at: :asc)

      render json: list.as_json(
        only:   [ :id, :status, :exec_count ],
        include: { challenge: { only: [ :id, :title, :difficulty ] } }
      )
    end

    # PATCH/PUT /api/user_challenges/:id
    def update
      uc = current_user.user_challenges
                       .where(weekly_progress: @weekly)
                       .find(params[:id])
      uc.update!(update_params)

      render json: uc.as_json(only: [ :id, :status, :exec_count ])
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    # POST /api/user_challenges
    # パラメータ例: { diagnosis_result_id: 123, challenge_ids: [1,2,3] }
    def create
      ids = Array(params.require(:challenge_ids))
      unless ids.length.between?(1, 4)
        return render json: { error: "1〜4件選んでください" }, status: :unprocessable_entity
      end

      result = current_user.diagnosis_results.find(params[:diagnosis_result_id])
      weekly = result.weekly_progress

      # すでに同週で選んでいる challenge を除外
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
      # その週が無ければ作る（index/update どちらでも破綻しない）
      @weekly = guess_current_week_for(current_user) || resolve_current_week_for(current_user)
    end

    def update_params
      params.require(:user_challenge).permit(:status, :exec_count)
    end
  end
end
