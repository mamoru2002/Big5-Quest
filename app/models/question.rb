class Question < ApplicationRecord
  belongs_to :trait
  has_many   :responses
end
