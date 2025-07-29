class DiagnosisStart < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :diagnosis_result
end
