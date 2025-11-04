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

  def weekly_anchor_date_for(user, now_date: Date.current)
    user.weekly_progresses
        .where("start_at <= ?", now_date)
        .maximum(:start_at)&.to_date ||
      user.weekly_progresses.minimum(:start_at)&.to_date ||
      user.created_at.to_date
  end

  def weekly_window_state(user, now_date: Date.current)
    anchor = weekly_anchor_date_for(user, now_date: now_date)
    days   = (now_date - anchor).to_i
    case days
    when 0..6   then "in_week"
    when 7..13  then "diagnosis_required"
    else            "previous_week_missed"
    end
  end

  def ensure_weekly_window!
    return unless current_user && current_api_user_credential

    state = weekly_window_state(current_user)
    case state
    when "in_week"
      nil
    when "diagnosis_required"
      render json: { error: "diagnosis_required", next: "diagnosis" }, status: :forbidden
    else # "previous_week_missed"
      render json: { error: "previous_week_missed", next: "diagnosis" }, status: :forbidden
    end
  end

  def resolve_current_week_for(user)
    raise ArgumentError, "user is required" unless user

    today      = Time.zone.today
    first_anchor = user.weekly_progresses.minimum(:start_at)&.to_date || today
    weeks_since  = ((today - first_anchor).to_i) / 7
    start_at     = first_anchor + weeks_since * 7

    user.weekly_progresses.find_or_create_by!(start_at: start_at) do |rec|
      rec.week_no = (user.weekly_progresses.maximum(:week_no) || 0) + 1
    end
  end

  def guess_current_week_for(user)
    return nil unless user

    first_anchor = user.weekly_progresses.minimum(:start_at)&.to_date
    return nil unless first_anchor

    today       = Time.zone.today
    weeks_since = ((today - first_anchor).to_i) / 7
    start_at    = first_anchor + weeks_since * 7
    user.weekly_progresses.find_by(start_at: start_at)
  end
end
