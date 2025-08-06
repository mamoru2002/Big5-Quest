class UserProfile < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true
  validates :name,    presence: true, length: { maximum: 50 }
  validates :bio,     length: { maximum: 1000 }, allow_nil: true
end
