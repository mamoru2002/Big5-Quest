require "erb"

module Api
  module Auth
    class ConfirmationsController < Devise::ConfirmationsController
      skip_before_action :require_no_authentication, only: :create
      respond_to :json, :html

      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])
        fe = ENV.fetch("FRONTEND_BASE_URL", "https://app.big5-quest.com")
        if resource.errors.empty?
          redirect_to "#{fe}/signin?confirmed=1", allow_other_host: true
        else
          msg = ERB::Util.url_encode(resource.errors.full_messages.to_sentence)
          redirect_to "#{fe}/verify?error=#{msg}", allow_other_host: true
        end
      end

      def create
        cred = UserCredential.find_by!(email: params.require(:email))
        cred.resend_confirmation_instructions
        head :accepted
      rescue ActiveRecord::RecordNotFound
        head :accepted
      end
    end
  end
end

