module Api
  module Auth
    class RegistrationsController < ApplicationController
      skip_before_action :authenticate_api_user!, raise: false

      def create
        ApplicationRecord.transaction do
          user = User.create!
          UserProfile.create!(user: user, name: params[:name].presence || "ユーザー", bio: "")

          cred = UserCredential.create!(
            user: user,
            email: params.require(:email),
            password: params.require(:password),
            password_confirmation: params[:password_confirmation].presence || params[:password]
          )

          # Confirmable対応：未確認ならメール送って 202 を返す
          if cred.respond_to?(:confirmed?) && !cred.confirmed?
            # Devise Confirmable は save! 時に送信されますが、念のため明示
            cred.send_confirmation_instructions if Devise.mailer
            render json: { requires_confirmation: true }, status: :accepted
            return
          end

          sign_in(:api_user_credential, cred, store: false)
          token = request.env["warden-jwt_auth.token"]
          token ||= Warden::JWTAuth::UserEncoder.new.call(cred, :api_user_credential, nil).first
          response.set_header("Authorization", "Bearer #{token}") if token.present?

          render json: {
            token: token,
            user: { id: user.id, email: cred.email, name: user.user_profile&.name }
          }, status: :created
        end
      rescue ActionController::ParameterMissing => e
        render json: { errors: [ e.message ] }, status: :bad_request
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
end
