# frozen_string_literal: true

module DiagnosisResults
  class FormSelector
    def self.call(user:, weekly:)
      new(user: user, weekly: weekly).call
    end

    def initialize(user:, weekly:)
      @user   = user
      @weekly = weekly
      @info   = Weekly::ProgramInfo.new(user: user, weekly: weekly)
    end

    def call
      # 1週目と最終週は full_50
      return "full_50" if info.program_week.zero?
      return "full_50" if info.final_week?

      trait = info.focus_trait_code
      raise ArgumentError, "focus_trait_code is missing" if trait.blank?

      if info.milestone_week?
        bucket = info.milestone_bucket # "A" or "B"
        return "milestone_26_#{trait.downcase}_#{bucket.downcase}"
      end

      rot = info.rotation_bucket # "A" "B" "C" or nil(休止週)
      raise ArgumentError, "rotation_bucket is missing" if rot.blank?

      "target_forms_#{trait.downcase}_#{rot.downcase}"
    end

    private

    attr_reader :user, :weekly, :info
  end
end
