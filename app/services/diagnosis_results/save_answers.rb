# frozen_string_literal: true

class DiagnosisResults::SaveAnswers
  class ValidationFailed < StandardError; end
  class UnknownQuestionUuid < StandardError; end

  def self.call(result:, answers:)
    new(result, answers).call
  end

  def initialize(diagnosis_result, raw_answers)
    @diagnosis_result = diagnosis_result
    @raw_answers      = raw_answers
  end

  def call
    validate_payload!

    latest_answers_by_uuid = dedupe_answers(@normalized_answers)
    uuid_to_question_id    = resolve_question_ids(latest_answers_by_uuid.keys)

    saved_count = 0

    ActiveRecord::Base.transaction do
      latest_answers_by_uuid.each do |question_uuid, answer_value|
        question_id = uuid_to_question_id.fetch(question_uuid)

        response_record = Response.find_or_initialize_by(
          diagnosis_result_id: @diagnosis_result.id,
          question_id:         question_id
        )

        response_record.value = answer_value
        response_record.save!
        saved_count += 1
      end
    end

    saved_count

  rescue ActiveRecord::RecordInvalid => e
    message = e.record&.errors&.full_messages&.join(", ") || e.message
    raise ValidationFailed, message
  rescue KeyError => e
    raise UnknownQuestionUuid, e.message
  end

  private

  def validate_payload!
    unless @raw_answers.is_a?(Array)
      raise ValidationFailed, "responses must be an array"
    end

    normalized_answers = []

    @raw_answers.each_with_index do |answer_param, index|
      answer_hash =
        if answer_param.respond_to?(:to_unsafe_h)
          answer_param.to_unsafe_h
        elsif answer_param.respond_to?(:to_h)
          answer_param.to_h
        else
          nil
        end

      unless answer_hash.is_a?(Hash)
        raise ValidationFailed, "responses[#{index}] must be a hash"
      end

      question_uuid = answer_hash[:question_uuid] || answer_hash["question_uuid"]
      raw_value     = answer_hash[:value]         || answer_hash["value"]

      if question_uuid.nil? || question_uuid.to_s.strip.empty?
        raise ValidationFailed, "responses[#{index}].question_uuid is missing"
      end

      answer_value = begin
        Integer(raw_value)
      rescue StandardError
        nil
      end

      unless answer_value
        raise ValidationFailed, "responses[#{index}].value must be integer"
      end

      normalized_answers << {
        question_uuid: question_uuid.to_s,
        value:         answer_value
      }
    end

    @normalized_answers = normalized_answers
  end

  def dedupe_answers(answer_hashes)
    latest_answers_by_uuid = {}

    answer_hashes.reverse_each do |answer|
      uuid = answer[:question_uuid]
      latest_answers_by_uuid[uuid] ||= answer[:value]
    end

    latest_answers_by_uuid
  end

  def resolve_question_ids(question_uuids)
    uuid_to_question_id = Question.where(uuid: question_uuids)
                                  .pluck(:uuid, :id)
                                  .to_h

    unknown_uuids = question_uuids - uuid_to_question_id.keys
    if unknown_uuids.any?
      raise UnknownQuestionUuid, "unknown uuids: #{unknown_uuids.join(', ')}"
    end

    uuid_to_question_id
  end
end
