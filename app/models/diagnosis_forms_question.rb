class DiagnosisFormsQuestion < ApplicationRecord
  beliongs_to :diagnosis_form_id
  beliongs_to :question_id
end
