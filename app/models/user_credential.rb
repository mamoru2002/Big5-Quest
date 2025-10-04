class UserCredential < ApplicationRecord
  self.table_name = "user_credentials"

  belongs_to :user

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  alias_attribute :encrypted_password, :password_hash

  before_validation { self.email = email.to_s.strip.downcase }

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: true
  validates :password_hash, presence: true
end
