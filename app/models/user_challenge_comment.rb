class UserChallengeComment < ApplicationRecord
  belongs_to :user_challenge

  validates :comment,   presence: true, length: { maximum: 500 }
  validates :is_public, inclusion: { in: [ true, false ] }
end
