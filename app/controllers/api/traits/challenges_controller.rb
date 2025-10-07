module Api
  module Traits
    class ChallengesController < ApplicationController
      before_action :authenticate_api_user!
      before_action :ensure_weekly_window!
      def index
        trait = Trait.find_by!(code: params[:trait_code])
        @list = trait.challenges
                     .order(:difficulty)
                     .select(:id, :title, :difficulty)
        render :index
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      end
    end
  end
end
