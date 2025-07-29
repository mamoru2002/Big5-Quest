class UserChallenge < ApplicationRecord
  include AutoPresenceValidations
  has_one :user_challenge_comment, dependent: :destroy
  has_many :emotion_tags_user_challenges, dependent: :destroy
  has_many :likes, dependent: :destroy
  belongs_to :user
  belongs_to :challenge

  enum status: { unstarted: 0, executing: 1, expired: 2 }
  validates :exec_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
