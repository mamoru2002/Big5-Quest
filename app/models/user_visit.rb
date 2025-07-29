class UserVisit < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :user

  validates :token, uniqueness: true
end
