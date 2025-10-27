
# frozen_string_literal: true
namespace :weekly do
  desc "End-of-week processing: expire past challenges and ensure current WeeklyProgress exists for all users"
  task rollover: :environment do
    puts "[weekly:rollover] start: #{Time.zone.now}"
    Weekly::Rollover.call
    puts "[weekly:rollover] done: #{Time.zone.now}"
  end
end
