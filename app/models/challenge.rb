class Challenge < ApplicationRecord
  belongs_to :trait
  has_many   :user_challenges, dependent: :restrict_with_error

  validates :title,      presence: true
  validates :difficulty, presence: true, inclusion: { in: 1..10 }
end
