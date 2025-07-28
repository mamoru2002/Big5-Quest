class DiagnosisFormsQuestion < ApplicationRecord
  belongs_to :diagnosis_form
  belongs_to :question
end
