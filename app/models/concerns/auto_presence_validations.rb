module AutoPresenceValidations
  extend ActiveSupport::Concern

  included do
    self.columns_hash.each do |name, col|
      next if %w[id created_at updated_at].include?(name)
      if col.null == false
        validates name.to_sym, presence: true
      end
    end
  end
end
