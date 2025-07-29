class DiagnosisCompletion < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :diagnosis_result
end
