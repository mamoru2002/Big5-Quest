# frozen_string_literal: true

class UserChallenges::Update
  class ValidationFailed < StandardError; end
  class NotFound < StandardError; end

  def self.call(user:, weekly:, id:, params:)
    new(user, weekly, id, params).call
  end

  def initialize(user, weekly, id, params)
    @user   = user
    @weekly = weekly
    @id     = id
    @params = params
  end

  def call
    p = normalize_params!(@params)

    user_challenge = @user.user_challenges
                          .where(weekly_progress: @weekly)
                          .lock(true)
                          .find(@id)

    ActiveRecord::Base.transaction do
      attrs = {}
      attrs[:status]     = p[:status]     if p.key?(:status)
      attrs[:exec_count] = p[:exec_count] if p.key?(:exec_count)
      user_challenge.update!(attrs) if attrs.any?

      if p.key?(:comment)
        body = p[:comment].to_s.strip
        if body.present?
          if user_challenge.user_challenge_comment
            user_challenge.user_challenge_comment.update!(comment: body)
          else
            user_challenge.create_user_challenge_comment!(comment: body)
          end
        end
      end

      if p.key?(:emotion_tag_ids)
        new_ids     = p[:emotion_tag_ids] # 既に整数uniq化済み
        current_ids = user_challenge.emotion_tags_user_challenges.pluck(:emotion_tag_id)
        to_add      = new_ids - current_ids
        to_remove   = current_ids - new_ids

        user_challenge.emotion_tags_user_challenges
                      .where(emotion_tag_id: to_remove)
                      .delete_all if to_remove.any?

        to_add.each do |tid|
          user_challenge.emotion_tags_user_challenges.find_or_create_by!(emotion_tag_id: tid)
        end
      end
    end

    user_challenge.reload
  rescue ActiveRecord::RecordNotFound
    raise NotFound, "UserChallenge not found"
  rescue ActiveRecord::RecordInvalid => e
    raise ValidationFailed, e.record.errors.full_messages.join(", ")
  end

  private

  def normalize_params!(raw)
    h =
      if raw.respond_to?(:to_unsafe_h)
        raw.to_unsafe_h
      elsif raw.respond_to?(:to_h)
        raw.to_h
      else
        raise ValidationFailed, "params must be a hash"
      end

    h = h.transform_keys { |k| k.to_sym rescue k }

    out = {}
    out[:status] = h[:status] if h.key?(:status)

    if h.key?(:exec_count)
      out[:exec_count] = Integer(h[:exec_count])
    end

    out[:comment] = h[:comment] if h.key?(:comment)

    if h.key?(:emotion_tag_ids)
      out[:emotion_tag_ids] = Array(h[:emotion_tag_ids]).map { |v| Integer(v) }.uniq
    end

    out
  rescue ArgumentError
    raise ValidationFailed, "invalid parameter type"
  end
end
