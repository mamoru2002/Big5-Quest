class DiagnosisCompletion < ApplicationRecord
  belongs_to :diagnosis_result

  validates :diagnosis_result_id, uniqueness: true
end
