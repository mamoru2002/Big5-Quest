class UserCredential < ApplicationRecord
  belongs_to :user

  devise :database_authenticatable, :registerable,
         :recoverable, :confirmable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  before_validation { self.email = email.to_s.strip.downcase }

  validates :email, length: { maximum: 255 }, allow_blank: true
end
