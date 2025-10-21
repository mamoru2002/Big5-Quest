require 'rails_helper'

RSpec.describe WeeklyPause, type: :model do
  it "同一weekly_progressに二重作成はDB制約違反" do
    wp = create(:weekly_progress)
    create(:weekly_pause, weekly_progress: wp)

    expect {
      create(:weekly_pause, weekly_progress: wp)
    }.to raise_error { |error|
      expect(error).to be_a(ActiveRecord::RecordNotUnique)
        .or be_a(ActiveRecord::StatementInvalid)
    }
  end
end
