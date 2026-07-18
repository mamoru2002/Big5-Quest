# frozen_string_literal: true

class GuestCleanupJob < ApplicationJob
  queue_as :default

  def perform
    User.expired_guests.find_each(&:destroy!)
  end
end
