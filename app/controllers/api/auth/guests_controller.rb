module Api
  module Auth
    class GuestsController < ApplicationController
      skip_before_action :authenticate_api_user!, raise: false
      before_action :force_json_format

      def create
        ActiveRecord::Base.transaction do
          guest_email = "guest_user_#{SecureRandom.hex(8)}@example.com"

          user_attrs = {}
          user_attrs[:email] = guest_email if User.column_names.include?("email")
          user = User.create!(user_attrs)

          if defined?(UserProfile) && UserProfile.column_names.include?("name")
            UserProfile.create!(user_id: user.id, name: "Guest #{SecureRandom.hex(3)}")
          end

          cred = UserCredential.new(user: user, email: guest_email)
          tmp  = SecureRandom.hex(16)
          cred.password              = tmp
          cred.password_confirmation = tmp

          cred.skip_confirmation_notification! if cred.respond_to?(:skip_confirmation_notification!)
          cred.skip_confirmation!              if cred.respond_to?(:skip_confirmation!)
          cred.save!

          sign_in(:api_user_credential, cred, store: false)
          token = request.env["warden-jwt_auth.token"] ||
                  response.get_header("Authorization")&.split(" ")&.last ||
                  Warden::JWTAuth::UserEncoder.new.call(cred, :api_user_credential, nil).first

          form = DiagnosisForm.find_by(name: "guest_10")
          next_diag = nil
          if form
            weekly = resolve_current_week_for(user)
            result = DiagnosisResult.find_or_create_by!(user: user, weekly_progress: weekly) do |r|
              r.diagnosis_form = form
            end
            DiagnosisStart.find_or_create_by!(diagnosis_result: result)
            next_diag = { form_name: form.name, result_id: result.id }
          end

          response.set_header("Authorization", "Bearer #{token}") if token.present?

          render json: {
            token: token,
            user:  { id: user.id, guest: true },
            next_diagnosis: next_diag
          }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotUnique => e
        render json: { error: "duplicate_email", message: e.message }, status: :conflict
      rescue => e
        render json: { error: e.class.name, message: e.message }, status: :internal_server_error
      end

      private
      def force_json_format = request.format = :json
    end
  end
end
