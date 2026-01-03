module Api
  class DiagnosisResultsController < ApplicationController
    before_action :authenticate_api_user!
    def show
      @result = current_user.diagnosis_results.find(params[:id])
      render :show
    end

    def create
      weekly = resolve_current_week_for(current_user)

      requested_form_name = params.dig(:diagnosis_result, :form_name)
      form_name =
        if requested_form_name.present?
          requested_form_name
        else
          DiagnosisResults::FormSelector.call(user: current_user, weekly: weekly)
        end

      form = DiagnosisForm.find_by!(name: form_name)

      result = DiagnosisResult.find_or_initialize_by(
        user: current_user,
        weekly_progress: weekly
      ) do |r|
        r.diagnosis_form = form
        r.status         = :incomplete
      end

      if result.new_record?
        result.save!
        DiagnosisStart.create!(diagnosis_result: result)
      end

      render json: { id: result.id, form_name: form.name }, status: :created
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
      @result = current_user.diagnosis_results.find(params[:id])

      DiagnosisCompletion.find_or_create_by!(diagnosis_result: @result)
      @result.update!(status: :complete) unless @result.complete?

      render :complete
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
