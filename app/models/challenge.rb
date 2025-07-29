class Challenge < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :trait
  has_many :user_challenges, dependent: :restrict_with_error


  validates :difficulty,
            inclusion: { in: 1..10 }  # 難易度は1〜10
end
