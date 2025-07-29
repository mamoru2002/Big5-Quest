class EmotionTag < ApplicationRecord
  include AutoPresenceValidations

  has_many :emotion_tags_user_challenges
end
