module Api
  class DiagnosisResultsController < ApplicationController
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

    def answers
      result = current_user.diagnosis_results.find(params[:id])
      pms = params.require(:answers)

      uuids      = pms.map { |a| a[:question_uuid] }
      uuid_to_id = Question.where(uuid: uuids).pluck(:uuid, :id).to_h

      rows = pms.map do |a|
        {
          diagnosis_result_id: result.id,
          question_id:         uuid_to_id.fetch(a[:question_uuid]),
          value:               a[:value].to_i,
          created_at:          Time.current,
          updated_at:          Time.current
        }
      end
      Response.insert_all!(rows)
      render json: { saved: rows.size }, status: :created

    rescue KeyError, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def complete
      @result = current_user.diagnosis_results.find(params[:id])

      DiagnosisCompletion.create!(diagnosis_result: @result)
      @result.update!(status: :complete)

      render :complete
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
