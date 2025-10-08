module Api
  module Auth
    class GuestsController < ApplicationController
      skip_before_action :authenticate_api_user!, raise: false
      before_action :force_json_format  # ★追加

      def create
        ActiveRecord::Base.transaction do
          guest_email = "guest_user_#{SecureRandom.hex(8)}@example.com"

          # User 側に Devise がある/なし 両対応
          user_attrs = { email: guest_email }
          if User.method_defined?(:password=)
            pwd = SecureRandom.hex(12)
            user_attrs[:password]              = pwd
            user_attrs[:password_confirmation] = pwd
          end
          user = User.create!(user_attrs)

          # UserCredential は Devise 正攻法で保存（password= 経由）
          cred = UserCredential.new(user: user, email: guest_email)
          cred_pwd = SecureRandom.hex(16)
          cred.password              = cred_pwd
          cred.password_confirmation = cred_pwd
          cred.save!

          sign_in(:api_user_credential, cred, store: false)
          token = request.env["warden-jwt_auth.token"]
          token ||= response.get_header("Authorization")&.split(" ")&.last
          if token.blank?
            token, _payload = Warden::JWTAuth::UserEncoder.new.call(cred, :api_user_credential, nil)
          end

          response.set_header("Authorization", "Bearer #{token}") if token.present?
          render json: { token: token, user: { id: user.id, guest: true } }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      private
      def force_json_format
        request.format = :json
      end
    end
  end
end
