module Api
  class UserChallengesController < ApplicationController
    def create
      ids = params.require(:challenge_ids)

      raise "1〜4件選んでください" unless ids.length.between?(1, 4)

      result = current_user.diagnosis_results.find(params[:diagnosis_result_id])

      ids.each do |c_id|
        UserChallenge.create!(
          user:            current_user,
          challenge_id:    c_id,
          weekly_progress: result.weekly_progress,
          status:          :unstarted
        )
      end

      head :created
    end
  end
end
