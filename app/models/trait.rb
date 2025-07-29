class Trait < ApplicationRecord
  include AutoPresenceValidations
  has_many :questions, dependent: :restrict_with_error
  has_many :challenges, dependent: :restrict_with_error

  validates :code, uniqueness: true
end
