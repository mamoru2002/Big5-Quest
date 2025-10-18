class Api::WeekSkipsController < ApplicationController
  before_action :authenticate_api_user_credential!

  def status
    render json: build_payload
  end

  def update
    want_skip = ActiveModel::Type::Boolean.new.cast(params[:skip])
    if want_skip
      ensure_reserved_once!
    else
      cancel_if_possible!
    end
    render json: build_payload
  end

  private

  def current_user
    @current_user ||= current_api_user_credential.user
  end

  def next_week_start
    Date.current.beginning_of_week + 1.week
  end

  def next_week_progress
    @next_week_progress ||= begin
      wp = WeeklyProgress.find_by(user_id: current_user.id, start_at: next_week_start)
      return wp if wp
      next_no = (WeeklyProgress.where(user_id: current_user.id).maximum(:week_no) || 0) + 1
      WeeklyProgress.create!(user_id: current_user.id, week_no: next_no, start_at: next_week_start)
    end
  end

  def pause_exists?
    WeeklyPause.exists?(weekly_progress_id: next_week_progress.id)
  end

  def ensure_reserved_once!
    return if pause_exists?
    WeeklyPause.create!(weekly_progress_id: next_week_progress.id)
  end

  def cancel_if_possible!
    if (pause = WeeklyPause.find_by(weekly_progress_id: next_week_progress.id))
      pause.destroy
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
    WeeklyPause.joins(:weekly_progress)
               .where(weekly_progresses: { user_id: current_user.id })
               .count
  end

  def remaining_skips
    [max_skips - total_used_skips, 0].max
  end
end