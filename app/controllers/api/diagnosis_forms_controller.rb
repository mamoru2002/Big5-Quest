module Api
  class DiagnosisFormsController < ApplicationController
    def questions
      form = DiagnosisForm.find_by!(name: params[:id])

      links = form.diagnosis_forms_questions.order(:question_order)

      render json: links.map { |link|
        q = link.question
        {
          uuid:  q.uuid,                 # ← UUID を返す
          body:  q.body,
          order: link.question_order
        }
      }
    end
  end
end
