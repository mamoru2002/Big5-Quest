module UserPrograms
  class EnsureActive
    def self.call(user:, weekly:, focus_trait_code:)
      new(user: user, weekly: weekly, focus_trait_code: focus_trait_code).call
    end

    def initialize(user:, weekly:, focus_trait_code:)
      @user             = user
      @weekly           = weekly
      @focus_trait_code = focus_trait_code
    end

    def call
      user.with_lock do
        program = user.user_programs.active.order(start_at: :desc).first
        return program if program

        trait_code = focus_trait_code.to_s.upcase
        raise ActiveRecord::RecordNotFound, "Trait not found" unless Trait.exists?(code: trait_code)

        UserProgram.create!(
          user:             user,
          focus_trait_code: trait_code,
          start_at:         weekly.start_at,
          status:           :active
        )
      end
    end

    private

    attr_reader :user, :weekly, :focus_trait_code
  end
end
