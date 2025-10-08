module Api
  module Auth
    class GuestsController < ApplicationController
      skip_before_action :authenticate_api_user!, raise: false

      def create
        ActiveRecord::Base.transaction do
          guest_email = "guest_user_#{SecureRandom.hex(8)}@example.com"
          user = User.create!(email: guest_email)
          cred = UserCredential.new(
          user:         user,
          email:        guest_email,
          password_hash: SecureRandom.hex(32)
        )
          cred.save!(validate: false)

          sign_in(:api_user_credential, cred, store: false)
          scope = :api_user_credential
          token, _payload = Warden::JWTAuth::UserEncoder.new.call(cred, scope, nil)
          response.set_header("Authorization", "Bearer #{token}")
          render json: { token: token, user: { id: user.id, guest: true } }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end
  end
end
