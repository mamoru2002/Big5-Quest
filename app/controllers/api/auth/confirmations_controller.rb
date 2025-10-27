module Api
  module Auth
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json, :html

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
        cred = UserCredential.find_by(email: email)
        cred&.resend_confirmation_instructions
        head :accepted
      end
    end
  end
end
