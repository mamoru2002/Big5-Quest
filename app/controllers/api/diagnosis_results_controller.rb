# app/controllers/api/diagnosis_results_controller.rb
module Api
  class DiagnosisResultsController < ApplicationController
    before_action :authenticate_api_user!
    def show
      @result = current_user.diagnosis_results.find(params[:id])
      render :show
    end

    def create
      pms    = params.require(:diagnosis_result).permit(:form_name)
      form   = DiagnosisForm.find_by!(name: pms[:form_name])
      weekly = resolve_current_week_for(current_user)

      result = DiagnosisResult.find_or_initialize_by(
        user:            current_user,
        weekly_progress: weekly
      ) do |r|
        r.diagnosis_form = form
        r.status         = :incomplete
      end

      if result.new_record?
        result.save!
        DiagnosisStart.create!(diagnosis_result: result)
      end

      render json: { id: result.id }, status: :created
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
