class UserProgram < ApplicationRecord
  belongs_to :user

  enum :status, {
    active: 0,
    completed: 1,
    canceled: 2
  }

  validates :focus_trait_code, presence: true
  validates :focus_trait_code, inclusion: { in: %w[N E C] }
  validates :start_at, presence: true
end
