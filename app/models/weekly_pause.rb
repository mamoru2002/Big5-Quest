class WeeklyPause < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :weekly_progress
end
