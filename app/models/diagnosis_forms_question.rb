class DiagnosisFormsQuestion < ApplicationRecord
  belongs_to :diagnosis_form
  belongs_to :question

  validates :question_order, presence: true,
                             numericality: { only_integer: true, greater_than: 0 }
  validates :question_id, uniqueness: { scope: :diagnosis_form_id }
end
