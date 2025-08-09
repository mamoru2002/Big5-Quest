class ApplicationController < ActionController::API
    private
  def current_user
    User.first || User.create!
  end

  def resolve_current_week_for(user)
    today  = Time.zone.today
    anchor = user.weekly_progresses.minimum(:start_at)&.to_date || today

    weeks_since = ((today - anchor).to_i) / 7
    start_at    = anchor + weeks_since * 7

    user.weekly_progresses.find_or_create_by!(start_at: start_at) do |rec|
      rec.week_no = (user.weekly_progresses.maximum(:week_no) || 0) + 1
    end
  end

  def guess_current_week_for(user)
    anchor = user.weekly_progresses.minimum(:start_at)&.to_date
    return nil unless anchor

    today      = Time.zone.today
    weeks_since = ((today - anchor).to_i) / 7
    start_at    = anchor + weeks_since * 7
    user.weekly_progresses.find_by(start_at: start_at)
  end
end
