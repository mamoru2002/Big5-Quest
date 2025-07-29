class UserProfile < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :user

  validates :user_id, uniqueness: true
end
