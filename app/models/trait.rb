class Trait < ApplicationRecord
  has_many :questions,  dependent: :restrict_with_error
  has_many :challenges, dependent: :restrict_with_error

  validates :code,    presence: true, uniqueness: true, length: { is: 1 }
  validates :name_ja, presence: true, length: { maximum: 20 }
  validates :name_en, presence: true, length: { maximum: 20 }
end
