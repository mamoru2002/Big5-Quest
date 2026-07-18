# frozen_string_literal: true

class DiagnosisResults::Complete
  class IncompleteAnswers < StandardError; end

  def self.call(result:)
    new(result).call
  end

  def initialize(result)
    @result = result
  end

  def call
    ApplicationRecord.transaction do
      result.lock!

      expected_ids = result.diagnosis_form.questions.pluck(:id).sort
      answered_ids = result.responses.distinct.pluck(:question_id).sort

      if expected_ids.empty? || answered_ids != expected_ids
        missing_count = (expected_ids - answered_ids).length
        unexpected_count = (answered_ids - expected_ids).length
        raise IncompleteAnswers,
              "diagnosis answers are incomplete (missing=#{missing_count}, unexpected=#{unexpected_count})"
      end

      DiagnosisCompletion.find_or_create_by!(diagnosis_result: result)
      result.update!(status: :complete) unless result.complete?
      result.reload
    end
  end

  private

  attr_reader :result
end
