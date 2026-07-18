# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserChallenges::Update do
  it "records completion separately from expiration" do
    user = User.create!
    weekly = WeeklyProgress.create!(user: user, week_no: 1, start_at: Date.current)
    trait = Trait.create!(code: "N", name_ja: "情緒安定性", name_en: "Neuroticism")
    challenge = Challenge.create!(trait: trait, title: "深呼吸する", difficulty: 1)
    user_challenge = UserChallenge.create!(
      user: user,
      weekly_progress: weekly,
      challenge: challenge,
      status: :unstarted,
      exec_count: 0
    )

    updated = described_class.call(
      user: user,
      weekly: weekly,
      id: user_challenge.id,
      params: { status: "completed", exec_count: 0 }
    )

    expect(updated).to be_completed
    expect(updated.exec_count).to eq(1)
    expect(updated.first_done_at).to be_present
  end

  it "treats the legacy expired payload with an execution as completed" do
    user = User.create!
    weekly = WeeklyProgress.create!(user: user, week_no: 1, start_at: Date.current)
    trait = Trait.create!(code: "C", name_ja: "誠実性", name_en: "Conscientiousness")
    challenge = Challenge.create!(trait: trait, title: "予定を立てる", difficulty: 1)
    user_challenge = UserChallenge.create!(
      user: user,
      weekly_progress: weekly,
      challenge: challenge,
      status: :unstarted,
      exec_count: 0
    )

    updated = described_class.call(
      user: user,
      weekly: weekly,
      id: user_challenge.id,
      params: { status: "expired", exec_count: 1 }
    )

    expect(updated).to be_completed
    expect(updated.first_done_at).to be_present
  end
end
