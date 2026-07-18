class WeeklyMiss < ApplicationRecord
  belongs_to :weekly_progress

  validates :weekly_progress_id, uniqueness: true
end
