class UserVisit < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true, length: { is: 64 }
end
