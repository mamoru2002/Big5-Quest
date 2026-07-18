# frozen_string_literal: true

namespace :guests do
  desc "Delete expired guest users and their dependent data"
  task cleanup: :environment do
    deleted = 0
    User.expired_guests.find_each do |user|
      user.destroy!
      deleted += 1
    end
    puts "[guests:cleanup] deleted=#{deleted}"
  end
end
