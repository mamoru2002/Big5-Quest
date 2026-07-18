# frozen_string_literal: true

class UserChallenges::Create
  class ValidationFailed < StandardError; end

  def self.call(user:, weekly:, diagnosis_result_id:, challenge_ids:, focus_trait_code: nil)
    new(
      user: user,
      weekly: weekly,
      diagnosis_result_id: diagnosis_result_id,
      challenge_ids: challenge_ids,
      focus_trait_code: focus_trait_code
    ).call
  end

  def initialize(user:, weekly:, diagnosis_result_id:, challenge_ids:, focus_trait_code:)
    @user = user
    @weekly = weekly
    @diagnosis_result_id = diagnosis_result_id
    @challenge_ids = challenge_ids
    @focus_trait_code = focus_trait_code
  end

  def call
    ids = normalize_ids!

    ApplicationRecord.transaction do
      user.lock!

      diagnosis_result = user.diagnosis_results.find_by!(
        id: diagnosis_result_id,
        weekly_progress: weekly
      )
      unless diagnosis_result.complete? && diagnosis_result.diagnosis_completion
        raise ValidationFailed, "診断を完了してから選択してください"
      end

      program = user.active_user_program
      trait_code = (program&.focus_trait_code.presence || focus_trait_code).to_s.upcase
      trait = Trait.find_by(code: trait_code)
      raise ValidationFailed, "invalid focus_trait_code" unless trait

      valid_ids = trait.challenges.where(id: ids).pluck(:id)
      invalid_ids = ids - valid_ids
      if invalid_ids.any?
        raise ValidationFailed, "選択した特性に属さないチャレンジが含まれています"
      end

      UserPrograms::EnsureActive.call(
        user: user,
        weekly: weekly,
        focus_trait_code: trait.code
      )

      existing_ids = user.user_challenges
                         .where(weekly_progress: weekly)
                         .pluck(:challenge_id)
      new_ids = ids - existing_ids
      if new_ids.empty?
        0
      else
        if existing_ids.length + new_ids.length > 4
          raise ValidationFailed, "1週間に選べるチャレンジは4件までです"
        end

        new_ids.each do |challenge_id|
          UserChallenge.create!(
            user: user,
            challenge_id: challenge_id,
            weekly_progress: weekly,
            status: :unstarted,
            exec_count: 0
          )
        end

        new_ids.length
      end
    end
  rescue ActiveRecord::RecordNotFound
    raise ValidationFailed, "診断結果が見つかりません"
  rescue ActiveRecord::RecordInvalid => e
    raise ValidationFailed, e.record.errors.full_messages.join(", ")
  end

  private

  attr_reader :user, :weekly, :diagnosis_result_id, :challenge_ids, :focus_trait_code

  def normalize_ids!
    ids = Array(challenge_ids).map { |value| Integer(value) }.uniq
    raise ValidationFailed, "1〜4件選んでください" unless ids.length.between?(1, 4)

    ids
  rescue ArgumentError, TypeError
    raise ValidationFailed, "challenge_ids must contain integers"
  end
end
