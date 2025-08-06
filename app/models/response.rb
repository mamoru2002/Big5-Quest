class Response < ApplicationRecord
  belongs_to :diagnosis_result
  belongs_to :question

  validates :value, presence: true, inclusion: { in: 1..5 }
end
