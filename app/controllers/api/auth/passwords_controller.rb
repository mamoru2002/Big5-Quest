module Api
  module Auth
    class PasswordsController < Devise::PasswordsController
      respond_to :json

      def create
        email = params.require(:email).to_s.strip.downcase
        UserCredential.send_reset_password_instructions(email: email)
        head :accepted
      end

      def update
        self.resource = UserCredential.reset_password_by_token(update_params)
        if resource.errors.empty?
          head :ok
        else
          render json: { error: resource.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      private
      def update_params
        params.permit(:reset_password_token, :password, :password_confirmation)
      end
    end
  end
end
