class EmotionTagsUserChallenge < ApplicationRecord
  belongs_to :emotion_tag
  belongs_to :user_challenge

  validates :emotion_tag_id, uniqueness: { scope: :user_challenge_id }
end
