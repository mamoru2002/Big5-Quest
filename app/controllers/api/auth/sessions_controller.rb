module Api
  module Auth
    class SessionsController < ApplicationController
      before_action :force_json_format

      def create
        email = params[:email].to_s.downcase
        cred  = UserCredential.find_for_database_authentication(email: email)
        unless cred&.valid_password?(params[:password])
          return render(json: { error: "invalid_credentials", message: "メールアドレスまたはパスワードが正しくありません。" }, status: :unauthorized)
        end

        if cred.respond_to?(:confirmed?) && !cred.confirmed?
          cred.resend_confirmation_instructions
          return render(json: { error: "unconfirmed", message: "メール認証が完了していません。受信トレイをご確認のうえ、確認メールのリンクを開いてください。" }, status: :forbidden)
        end

        # Devise フックは動かすがセッションは使わない
        sign_in(:api_user_credential, cred, store: false)

        # JWT を明示的に発行
        scope = :api_user_credential
        token, _payload = Warden::JWTAuth::UserEncoder.new.call(cred, scope, nil)
        response.set_header("Authorization", "Bearer #{token}")
        render json: { token: token, user: { id: cred.user_id, email: cred.email } }, status: :ok
      end

      def destroy
        sign_out(:api_user_credential) if current_api_user_credential
        head :no_content
      end

      before_action :authenticate_api_user_credential!, only: :me
      def me
        cred = current_api_user_credential
        render json: { id: cred.user_id, email: cred.email }
      end

      private
      def force_json_format
        request.format = :json
      end
    end
  end
end
