module Api
  module Auth
    class GuestsController < ApplicationController
      def create
        email = "guest_#{SecureRandom.hex(8)}@example.com"
        pwd   = SecureRandom.base58(16)

        ApplicationRecord.transaction do
          user = User.create!
          cred = UserCredential.create!(
            user: user, email: email,
            password: pwd, password_confirmation: pwd
          )
          sign_in(:api_user_credential, cred)
          token = request.env["warden-jwt_auth.token"]
          render json: { token:, user: { id: user.id, email: cred.email, guest: true } }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
