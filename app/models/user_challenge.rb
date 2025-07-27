class UserChallenge < ApplicationRecord
  has_one :user_challenge_comment
  has_many :emotion_tags_user_challenge
  has_many :likes
  belongs_to :user
  belongs_to :challenge
end
