class UserChallenge < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  belongs_to :weekly_progress

  has_one  :user_challenge_comment,       dependent: :destroy
  has_many :emotion_tags_user_challenges, dependent: :destroy
  has_many :likes,                         dependent: :destroy

  enum :status, { unstarted: 0, executing: 1, expired: 2 }
  validates :status, presence: true

  validates :exec_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :user_id, uniqueness: { scope: [ :challenge_id, :weekly_progress_id ] }
end
