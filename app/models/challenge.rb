class Challenge < ApplicationRecord
  belongs_to :trait
  has_many :user_challenge
end
