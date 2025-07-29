class Like < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :user
  belongs_to :user_challenge
end
