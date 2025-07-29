class DiagnosisFormsQuestion < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :diagnosis_form
  belongs_to :question
end
