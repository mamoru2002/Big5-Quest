class EmotionTagsUserChallenge < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :emotion_tag
  belongs_to :user_challenge
end
