module Api
  module Auth
    class GuestsController < ApplicationController
      skip_before_action :authenticate_api_user!, raise: false

      def create
        ActiveRecord::Base.transaction do
          guest_email = "guest_user_#{SecureRandom.hex(8)}@example.com"

          user_attrs = { email: guest_email }
          if User.method_defined?(:password=)
            pwd = SecureRandom.hex(12)
            user_attrs[:password]              = pwd
            user_attrs[:password_confirmation] = pwd
          end
          user = User.create!(user_attrs)

          cred = UserCredential.new(user: user, email: guest_email)
          cred_pwd = SecureRandom.hex(16)
          cred.password              = cred_pwd
          cred.password_confirmation = cred_pwd
          cred.save!

          sign_in(:api_user_credential, cred, store: false)
          token = request.env["warden-jwt_auth.token"]

          response.set_header("Authorization", "Bearer #{token}") if token
          render json: { token: token, user: { id: user.id, guest: true } }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end
  end
end
