class User < ApplicationRecord
  include AutoPresenceValidations
  has_one :user_profile,  dependent: :destroy
  has_one :user_visit,  dependent: :destroy
  has_one :user_credential,  dependent: :destroy
  has_many :diagnosis_results,  dependent: :destroy
  has_many :user_challenges,  dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :weekly_progresses, dependent: :destroy
end
