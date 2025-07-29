class DiagnosisForm < ApplicationRecord
  include AutoPresenceValidations
  has_many :diagnosis_forms_questions, dependent: :restrict_with_error
  has_many :diagnosis_results, dependent: :restrict_with_error
end
