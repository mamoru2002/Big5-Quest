class WeeklyProgress < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :user
  has_many :user_challenges, dependent: :destroy
  has_many :diagnosis_results, dependent: :destroy
  has_many :weekly_misses,  dependent: :destroy
  has_many :weekly_pauses,  dependent: :destroy

  validates :week_no,  numericality: { only_integer: true, greater_than: 0 },
                       uniqueness: { scope: :user_id }
end
