
# frozen_string_literal: true
module Weekly
  module Rotation
    # Returns 'A', 'B', or 'C' for a given week_no when counting only weekly (10-question) weeks.
    # Milestone weeks (26-question) are excluded from the weekly count.
    #
    # Rules (from spec):
    # - Weekly (10問): A→B→C rotates by *weekly* weeks only
    # - Milestones (26問): week 5 = 'A', week 10 = 'B' (do not count toward rotation steps)
    #
    # Note: If more milestone weeks are added in the future, extend MILESTONES map.
    MILESTONES = {
      5  => 'A',
      10 => 'B',
    }.freeze
    LETTERS = %w[A B C].freeze

    def self.milestone_letter_for(week_no)
      MILESTONES[week_no]
    end

    # Count weekly weeks before the given week_no (excluding milestone weeks)
    def self.weekly_index_before(week_no)
      return 0 if week_no <= 1
      excluded = MILESTONES.keys.select { |w| w < week_no }.count
      (week_no - 1) - excluded
    end

    # For a non-milestone week_no, compute the cycle letter (A/B/C), excluding milestones.
    def self.weekly_letter_for(week_no)
      raise ArgumentError, "week_no must be >= 1" unless week_no.is_a?(Integer) && week_no >= 1
      return nil if MILESTONES.key?(week_no) # milestones handled by milestone_letter_for
      idx = weekly_index_before(week_no)
      LETTERS[idx % LETTERS.size]
    end
  end
end
