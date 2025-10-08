module Api
  module Auth
    class GuestsController < ApplicationController
      skip_before_action :authenticate_api_user!, raise: false
      before_action :force_json_format

      def create
        ActiveRecord::Base.transaction do
          guest_email = "guest_user_#{SecureRandom.hex(8)}@example.com"

          user_attrs = {}
          user_attrs[:name] = "Guest #{SecureRandom.hex(4)}" if User.attribute_names.include?("name")
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
          token ||= response.get_header("Authorization")&.split(" ")&.last
          token ||= Warden::JWTAuth::UserEncoder.new.call(cred, :api_user_credential, nil).first

          response.set_header("Authorization", "Bearer #{token}") if token.present?
          render json: { token: token, user: { id: user.id, guest: true } }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      rescue => e
        render json: { error: e.class.name, message: e.message }, status: :internal_server_error
      end

      private
      def force_json_format
        request.format = :json
      end
    end
  end
end
