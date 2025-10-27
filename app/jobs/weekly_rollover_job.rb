
# frozen_string_literal: true
class WeeklyRolloverJob < ApplicationJob
  queue_as :default
  def perform
    Weekly::Rollover.call
  end
end
