module Api
  class DiagnosisResultsController < ApplicationController
    before_action :authenticate_api_user!
    def show
      @result = current_user.diagnosis_results.find(params[:id])
      render :show
    end

    def create
      weekly = resolve_current_week_for(current_user)

      result = ApplicationRecord.transaction do
        current_user.lock!
        existing = current_user.diagnosis_results.find_by(weekly_progress: weekly)

        unless existing
          form_name = DiagnosisResults::FormSelector.call(user: current_user, weekly: weekly)
          form = DiagnosisForm.find_by!(name: form_name)
          existing = current_user.diagnosis_results.create!(
            weekly_progress: weekly,
            diagnosis_form: form,
            status: :incomplete
          )
        end

        DiagnosisStart.find_or_create_by!(diagnosis_result: existing)
        existing
      end

      render json: { id: result.id, form_name: result.diagnosis_form.name }, status: :created
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end


    def responses
      result  = current_user.diagnosis_results.find(params[:id])
      payload = params.require(:responses)

      saved_count = DiagnosisResults::SaveAnswers.call(result: result, answers: payload)
      render json: { saved: saved_count }, status: :created
    rescue DiagnosisResults::SaveAnswers::ValidationFailed,
           DiagnosisResults::SaveAnswers::UnknownQuestionUuid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    end

    def complete
      result = current_user.diagnosis_results.find(params[:id])
      @result = DiagnosisResults::Complete.call(result: result)

      render :complete
    rescue DiagnosisResults::Complete::IncompleteAnswers => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
