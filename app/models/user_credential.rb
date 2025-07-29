class UserCredential < ApplicationRecord
  include AutoPresenceValidations
  belongs_to :user

  validates :email,         uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
end
