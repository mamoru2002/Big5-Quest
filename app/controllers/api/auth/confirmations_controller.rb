module Api
  module Auth
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json, :html

      before_action { request.env["devise.mapping"] ||= Devise.mappings[:api_user_credential] }

      skip_before_action :require_no_authentication, only: :create, raise: false
      skip_before_action :authenticate_api_user!, raise: false

      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])
        fe = ENV.fetch("FRONTEND_BASE_URL", "https://app.big5-quest.com")
        if resource.errors.empty?
          redirect_to "#{fe}/signin?confirmed=1"
        else
          msg = CGI.escape(resource.errors.full_messages.to_sentence)
          redirect_to "#{fe}/verify?error=#{msg}"
        end
      end

      def create
        email = params.require(:email).to_s.strip.downcase
        if (cred = UserCredential.find_by(email: email))
          begin
            cred.resend_confirmation_instructions
          rescue => e
            Rails.logger.error("resend_confirmation failed: #{e.class} #{e.message}")
          end
        end
        head :accepted
      end
    end
  end
end
