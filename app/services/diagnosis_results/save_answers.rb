# frozen_string_literal: true

class DiagnosisResults::SaveAnswers
  class ValidationFailed < StandardError; end
  class UnknownQuestionUuid < StandardError; end

  def self.call(result:, answers:)
    new(result, answers).call
  end

  def initialize(result, answers)
    @result  = result
    @answers = answers
  end

  def call
    validate_payload!
    latest     = dedupe_answers(@answers_normalized)
    uuid_to_id = resolve_question_ids(latest.keys)

    saved = 0
    ActiveRecord::Base.transaction do
      latest.each do |uuid, value|
        question_id = uuid_to_id.fetch(uuid)
        rec = Response.find_or_initialize_by(
          diagnosis_result_id: @result.id,
          question_id:         question_id
        )
        rec.value = value
        rec.save!
        saved += 1
      end
    end
    saved

  rescue ActiveRecord::RecordInvalid => e
    msg = e.record&.errors&.full_messages&.join(", ") || e.message
    raise ValidationFailed, msg
  rescue KeyError => e
    raise UnknownQuestionUuid, e.message
  end

  private

  def validate_payload!
    unless @answers.is_a?(Array)
      raise ValidationFailed, "answers must be an array"
    end

    normalized = []
    @answers.each_with_index do |elem, idx|
      unless elem.is_a?(Hash)
        raise ValidationFailed, "answers[#{idx}] must be a hash"
      end

      uuid = elem[:question_uuid] || elem["question_uuid"]
      raw  = elem[:value]         || elem["value"]

      if uuid.nil? || uuid.to_s.empty?
        raise ValidationFailed, "answers[#{idx}].question_uuid is missing"
      end

      int_value =
        begin
          Integer(raw)
        rescue StandardError
          nil
        end
      unless int_value
        raise ValidationFailed, "answers[#{idx}].value must be integer"
      end

      normalized << { question_uuid: uuid.to_s, value: int_value }
    end

    @answers_normalized = normalized
  end
  def dedupe_answers(arr)
    seen = {}
    arr.reverse_each do |h|
      uuid = h[:question_uuid]
      seen[uuid] ||= h[:value]
    end
    seen
  end

  def resolve_question_ids(uuids)
    map = Question.where(uuid: uuids).pluck(:uuid, :id).to_h
    unknown = uuids - map.keys
    if unknown.any?
      raise UnknownQuestionUuid, "unknown uuids: #{unknown.join(', ')}"
    end
    map
  end
end
