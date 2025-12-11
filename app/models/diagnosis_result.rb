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
    responses.includes(question: :trait)
            .group_by { |response| response.question.trait.code }
            .transform_values do |responses|
              scores = responses.map do |response|
                response.question.reverse_scored ? (6 - response.value) : response.value
              end
              (scores.sum.to_f / scores.size).round(2)
            end
  end
end
