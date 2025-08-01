module Api
  class DiagnosisFormsController < ApplicationController
    def questions
      form = DiagnosisForm.find_by!(name: params[:id])

      questions = form.questions.includes(:trait)

      render json: questions.map(&:body)
    end
  end
end
