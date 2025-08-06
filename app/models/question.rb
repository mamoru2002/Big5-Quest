class Question < ApplicationRecord
  belongs_to :trait
  has_many   :diagnosis_forms_questions, dependent: :restrict_with_error
  has_many   :responses,                 dependent: :restrict_with_error

  validates :body,  presence: true, length: { maximum: 200 }
  validates :uuid,  presence: true, uniqueness: true
  validates :reverse_scored, inclusion: { in: [ true, false ] }
end
