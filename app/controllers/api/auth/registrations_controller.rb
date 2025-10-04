module Api
  module Auth
    class RegistrationsController < ApplicationController
      def create
        ApplicationRecord.transaction do
          user = User.create!
          cred = UserCredential.new(user: user, email: params[:email])
          cred.password = params[:password]
          cred.password_confirmation = params[:password_confirmation]
          cred.save!

          sign_in(:api_user_credential, cred)
          token = request.env["warden-jwt_auth.token"]
          render json: { token:, user: { id: user.id, email: cred.email } }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: Array(e.record&.errors&.full_messages || e.message) }, status: :unprocessable_entity
      end
    end
  end
end
