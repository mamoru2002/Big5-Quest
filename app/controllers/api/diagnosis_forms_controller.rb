module Api
  class DiagnosisFormsController < ApplicationController
    def questions
      form = DiagnosisForm.find_by!(name: params[:name])

      links = form.diagnosis_forms_questions
                  .includes(:question)
                  .order(:question_order)

      render json: links.map { |link|
        q = link.question
        {
          question_uuid:  q.uuid,
          question_body:  q.body,
          question_order: link.question_order
        }
      }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Form not found" }, status: :not_found
    end
  end
end
