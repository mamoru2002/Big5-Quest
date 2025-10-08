module Api
  module Auth
    class GuestsController < ApplicationController
      skip_before_action :authenticate_api_user!, raise: false
      before_action :force_json_format

      def create
        Rails.logger.info "[guest_login] start"
        ActiveRecord::Base.transaction do
          guest_email = "guest_user_#{SecureRandom.hex(8)}@example.com"

          user_attrs = { email: guest_email }
          if User.attribute_names.include?("name") && user_attrs[:name].blank?
            user_attrs[:name] = "Guest #{SecureRandom.hex(4)}"
          end
          if User.method_defined?(:password=)
            pwd = SecureRandom.hex(12)
            user_attrs[:password]              = pwd
            user_attrs[:password_confirmation] = pwd
          end

          user = User.create!(user_attrs)
          Rails.logger.info "[guest_login] user created id=#{user.id}"

          cred = UserCredential.new(user: user, email: guest_email)
          cred_pwd = SecureRandom.hex(16)
          cred.password              = cred_pwd
          cred.password_confirmation = cred_pwd
          cred.save!
          Rails.logger.info "[guest_login] credential created id=#{cred.id}"

          sign_in(:api_user_credential, cred, store: false)
          Rails.logger.info "[guest_login] signed in"

          token = request.env["warden-jwt_auth.token"]
          Rails.logger.info "[guest_login] env_token?=#{token.present?}"
          token ||= response.get_header("Authorization")&.split(" ")&.last
          Rails.logger.info "[guest_login] header_token?=#{token.present?}"
          if token.blank?
            token, _payload = Warden::JWTAuth::UserEncoder.new.call(cred, :api_user_credential, nil)
            Rails.logger.info "[guest_login] manual_token?=#{token.present?}"
          end

          response.set_header("Authorization", "Bearer #{token}") if token.present?
          render json: { token: token, user: { id: user.id, guest: true } }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "[guest_login] AR::Invalid #{e.record.class} #{e.record.errors.full_messages}"
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      rescue => e
        Rails.logger.error "[guest_login] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
        render json: { error: e.class.name, message: e.message }, status: :internal_server_error
      end

      private
      def force_json_format
        request.format = :json
      end
    end
  end
end
