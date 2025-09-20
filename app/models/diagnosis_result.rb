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

  def scores_by_trait
        self.responses.includes(question: :trait)
            .group_by { |r| r.question.trait.code }
            .transform_values do |rs|
              vals = rs.map { |r| r.question.reverse_scored ? (6 - r.value) : r.value }
              (vals.sum.to_f / vals.size).round(2)
            end
  end
end
