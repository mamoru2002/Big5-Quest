class User < ApplicationRecord
  has_one :user_profile
  has_one :user_visit
  has_one :user_credential
  has_many :diagnosis_result
  has_many :user_challenge
  has_many :like
end
