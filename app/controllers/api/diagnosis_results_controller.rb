# app/controllers/api/diagnosis_results_controller.rb
module Api
  class DiagnosisResultsController < ApplicationController
    # POST /api/diagnosis_results
    # パラメータ例:
    def create
      pms  = params.require(:diagnosis_result).permit(:form_name)
      form = DiagnosisForm.find_by!(name: pms[:form_name])

      weekly = resolve_current_week_for(current_user)

      result = DiagnosisResult.create!(
        user:            current_user,
        diagnosis_form:  form,
        weekly_progress: weekly,
        status:          :incomplete
      )
      DiagnosisStart.create!(diagnosis_result: result)

      render json: { id: result.id }, status: :created

    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    # POST /api/diagnosis_results/:id/answers
    # パラメータ例:
    # { "answers": [ { "question_uuid":"...", "value":4 }, ... ] }
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

    # POST /api/diagnosis_results/:id/complete
    def complete
      result = current_user.diagnosis_results.find(params[:id])

      scores = compute_scores(result)   # 必要ならスコア算出
      DiagnosisCompletion.create!(diagnosis_result: result)
      result.update!(status: :complete)

      render json: { id: result.id, scores: scores }, status: :ok

    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    # 今週の WeeklyProgress をユーザーごとに見つける/作る
    def resolve_current_week_for(user)
      start = Date.current.beginning_of_week(:monday)  # 週の開始曜日は固定
      user.weekly_progresses.find_or_create_by!(start_at: start) do |rec|
        rec.week_no = (user.weekly_progresses.maximum(:week_no) || 0) + 1
      end
    end

    # 特性ごとの平均スコア（例）
    def compute_scores(result)
      result.responses.includes(question: :trait)
            .group_by { |r| r.question.trait.code }      # O/C/E/A/N
            .transform_values do |rs|
              vals = rs.map { |r| r.question.reverse_scored ? (6 - r.value) : r.value }
              (vals.sum.to_f / vals.size).round(2)
            end
    end
  end
end
