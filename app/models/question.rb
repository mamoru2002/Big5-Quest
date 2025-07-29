class Question < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :trait
  has_many   :responses, dependent: :restrict_with_error
  has_many :diagnosis_forms_questions, dependent: :restrict_with_error

  validates :body,           length: { maximum: 200 }
  validates :uuid,           uniqueness: true
  validates :reverse_scored, inclusion: { in: [ true, false ] }
end
