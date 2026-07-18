require 'rails_helper'

RSpec.describe WeeklyPause, type: :model do
  it "同一weekly_progressに二重作成できない" do
    wp = create(:weekly_progress)
    create(:weekly_pause, weekly_progress: wp)
    duplicate = build(:weekly_pause, weekly_progress: wp)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:weekly_progress_id]).to be_present
  end
end
