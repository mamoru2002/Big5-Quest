module Api
  class DiagnosisFormsController < ApplicationController
    def questions
      @form  = DiagnosisForm.find_by!(name: params[:name])
      @links = @form.diagnosis_forms_questions
                    .includes(:question)
                    .order(:question_order)
      render :questions, formats: :json
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Form not found" }, status: :not_found
    end
  end
end
