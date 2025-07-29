class Response < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :diagnosis_result
  belongs_to :question
end
