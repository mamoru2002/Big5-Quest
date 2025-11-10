class Api::WeekSkipsController < ApplicationController
  before_action :authenticate_api_user_credential!

  def status
    render json: build_payload
  end

  def update
    want_skip = ActiveModel::Type::Boolean.new.cast(params[:skip])
    want_skip ? ensure_reserved_once! : cancel_if_possible!
    render json: build_payload
  end

  private

  def current_user
    @current_user ||= current_api_user_credential.user
  end

  def next_week_start
    weekly_anchor_date_for(current_user) + 7.days
  end

  def peek_next_week_progress
    @peek_next_week_progress ||= current_user.weekly_progresses.find_by(start_at: next_week_start)
  end

  def resolve_next_week_progress
    peek_next_week_progress || current_user.weekly_progresses.create!(
      week_no:  current_user.weekly_progresses.maximum(:week_no).to_i + 1,
      start_at: next_week_start
    )
  end

  def pause_exists?
    wp = peek_next_week_progress
    wp && WeeklyPause.exists?(weekly_progress_id: wp.id)
  end

  def ensure_reserved_once!
    return if pause_exists?
    wp = resolve_next_week_progress
    WeeklyPause.find_or_create_by!(weekly_progress_id: wp.id)
  end

  def cancel_if_possible!
    wp = peek_next_week_progress
    return unless wp
    if (pause = WeeklyPause.find_by(weekly_progress_id: wp.id))
      pause.destroy!
    end
  end

  def build_payload
    {
      remaining: remaining_skips,
      used: total_used_skips,
      max: max_skips,
      next_week_paused: pause_exists?
    }
  end

  def max_skips
    3
  end

  def total_used_skips
    WeeklyPause.joins(:weekly_progress).where(weekly_progresses: { user_id: current_user.id }).count
  end

  def remaining_skips
    [ max_skips - total_used_skips, 0 ].max
  end
end
