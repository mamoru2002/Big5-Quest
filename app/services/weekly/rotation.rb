
# frozen_string_literal: true

# 週番号から A/B/C ローテーションやマイルストーン週を計算する純粋なヘルパー
module Weekly
  module Rotation
    MILESTONES = {
      5  => "A",
      10 => "B"
    }.freeze
    LETTERS = %w[A B C].freeze

    def self.milestone_letter_for(week_no)
      MILESTONES[week_no]
    end

    def self.weekly_index_before(week_no)
      return 0 if week_no <= 1
      excluded = MILESTONES.keys.select { |w| w < week_no }.count
      (week_no - 1) - excluded
    end

    def self.weekly_letter_for(week_no)
      raise ArgumentError, "week_no must be >= 1" unless week_no.is_a?(Integer) && week_no >= 1
      return nil if MILESTONES.key?(week_no)
      idx = weekly_index_before(week_no)
      LETTERS[idx % LETTERS.size]
    end
  end
end
