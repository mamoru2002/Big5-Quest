class UserChallengeComment < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :user_challenge
end
