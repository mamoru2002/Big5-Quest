class ApplicationController < ActionController::API
    private
  def current_user
    User.first || User.create!
  end
end
