class DiagnosisForm < ApplicationRecord
  has_many :diagnosis_question
  has_many :diagnosis_result
end
