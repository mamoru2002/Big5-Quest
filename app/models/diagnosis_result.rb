class DiagnosisResult < ApplicationRecord
  belongs_to :user
  belongs_to :diagnosis_form
  belongs_to :weekly_progress

  has_many :responses,             dependent: :destroy
  has_one  :diagnosis_start,       dependent: :destroy
  has_one  :diagnosis_completion,  dependent: :destroy

  enum :status, { incomplete: 0, complete: 1 }
  validates :status, presence: true

  validates :user_id, uniqueness: { scope: :weekly_progress_id }
end
