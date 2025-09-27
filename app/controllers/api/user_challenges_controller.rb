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
      user_challenge = current_user.user_challenges
                                   .where(weekly_progress: @weekly)
                                   .find(params[:id])

      ActiveRecord::Base.transaction do
        attrs = update_params.slice(:status, :exec_count)
        user_challenge.update!(attrs) if attrs.present?

        if update_params.key?(:comment)
          body = update_params[:comment].to_s.strip
          if body.present?
            if user_challenge.user_challenge_comment
              user_challenge.user_challenge_comment.update!(comment: body)
            else
              user_challenge.create_user_challenge_comment!(comment: body)
            end
          end
        end

        if update_params.key?(:emotion_tag_ids)
          new_ids     = Array(update_params[:emotion_tag_ids]).map(&:to_i).uniq
          current_ids = user_challenge.emotion_tags_user_challenges.pluck(:emotion_tag_id)
          to_add      = new_ids - current_ids
          to_remove   = current_ids - new_ids

          user_challenge.emotion_tags_user_challenges.where(emotion_tag_id: to_remove).delete_all if to_remove.any?
          to_add.each { |tid| user_challenge.emotion_tags_user_challenges.create!(emotion_tag_id: tid) }
        end
      end

      @user_challenge = user_challenge.reload
      render :update
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
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
