class DiagnosisResult < ApplicationRecord
  belongs_to :user
  belongs_to :diagnosis_form
  belongs_to :weekly_progress
end
