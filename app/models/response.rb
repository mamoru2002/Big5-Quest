class Response < ApplicationRecord
  belongs_to :diagnosis_result
  belongs_to :question
end
