class DiagnosisForm < ApplicationRecord
  has_many :diagnosis_forms_questions, dependent: :restrict_with_error
  has_many :questions, through: :diagnosis_forms_questions
  has_many :diagnosis_results,         dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true, length: { maximum: 20 }
end
