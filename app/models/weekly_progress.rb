class WeeklyProgress < ApplicationRecord
  belongs_to :user
  has_many :user_challenge
  has_many :diagnosis_result
  has_many :weekly_status_event
end
