class User < ApplicationRecord
  has_one  :user_profile,    dependent: :destroy
  has_one  :user_visit,      dependent: :destroy
  has_one  :user_credential, dependent: :destroy

  has_many :weekly_progresses,  dependent: :destroy
  has_many :diagnosis_results,  dependent: :destroy
  has_many :user_challenges,    dependent: :destroy
  has_many :likes,              dependent: :destroy
  has_many :user_programs, dependent: :destroy

  scope :expired_guests, -> { where(guest: true).where("guest_expires_at < ?", Time.current) }

  validates :guest_expires_at, presence: true, if: :guest?

  def active_user_program
    user_programs.active.order(start_at: :desc).first
  end
end
