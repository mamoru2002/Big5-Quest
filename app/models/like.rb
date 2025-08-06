class Like < ApplicationRecord
  belongs_to :user
  belongs_to :user_challenge

  validates :user_id, uniqueness: { scope: :user_challenge_id }
end
