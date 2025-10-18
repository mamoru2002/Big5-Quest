module Api
  class ProfilesController < ApplicationController
    before_action :authenticate_request!

    def show
      profile = UserProfile.find_by(user_id: current_user.id)
      render json: {
        name: profile&.name.to_s,
        bio:  profile&.bio.to_s
      }
    end

    def update
      p = UserProfile.find_or_initialize_by(user_id: current_user.id)
      p.assign_attributes(profile_params)
      p.save!
      render json: { name: p.name.to_s, bio: p.bio.to_s }
    end

    private

    def profile_params
      params.require(:profile).permit(:name, :bio)
    end

    def authenticate_request!
      head :unauthorized unless current_user
    end
  end
end