module Api
  class UserChallengesController < ApplicationController
    before_action :set_weekly

    # GET /api/user_challenges
    def index
      list = if @weekly
        current_user.user_challenges
                    .includes(:challenge)
                    .where(weekly_progress: @weekly)
                    .order(created_at: :asc)
      else
        UserChallenge.none
      end

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
    # { diagnosis_result_id: 123, challenge_ids: [1,2,3] }
    def create
      ids = Array(params.require(:challenge_ids))

      unless ids.length.between?(1, 4)
        return render json: { error: "1〜4件選んでください" }, status: :unprocessable_entity
      end

      result = current_user.diagnosis_results.find(params[:diagnosis_result_id])
      weekly = result.weekly_progress

      # すでに選んでいるものを除外
      existing = current_user.user_challenges
                             .where(weekly_progress: weekly, challenge_id: ids)
                             .pluck(:challenge_id)
      new_ids = ids.map(&:to_i) - existing
      if new_ids.empty?
        return head :no_content
      end

      # まとめて作成（必要なら insert_all でもOK）
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
      # 参照用：存在すれば取得、無ければ nil
      # 「必ず作る」挙動が欲しいなら resolve_current_week_for を使う
      @weekly = current_user.weekly_progresses
                            .find_by(start_at: Date.current.beginning_of_week(:monday))
    end

    def update_params
      params.require(:user_challenge).permit(:status, :exec_count)
    end
  end
end
