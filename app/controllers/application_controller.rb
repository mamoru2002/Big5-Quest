class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers
  private

  def current_user
    current_api_user_credential&.user
  end
  helper_method :current_user

  def authenticate_api_user!
    authenticate_api_user_credential!
    return if current_user

    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def resolve_current_week_for(user)
    raise ArgumentError, "user is required" unless user

    today  = Time.zone.today
    anchor = user.weekly_progresses.minimum(:start_at)&.to_date || today

    weeks_since = ((today - anchor).to_i) / 7
    start_at    = anchor + weeks_since * 7

    user.weekly_progresses.find_or_create_by!(start_at: start_at) do |rec|
      rec.week_no = (user.weekly_progresses.maximum(:week_no) || 0) + 1
    end
  end

  def guess_current_week_for(user)
    return nil unless user

    anchor = user.weekly_progresses.minimum(:start_at)&.to_date
    return nil unless anchor

    today       = Time.zone.today
    weeks_since = ((today - anchor).to_i) / 7
    start_at    = anchor + weeks_since * 7
    user.weekly_progresses.find_by(start_at: start_at)
  end
end
