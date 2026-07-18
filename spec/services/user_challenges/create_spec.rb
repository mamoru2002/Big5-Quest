# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserChallenges::Create do
  it "rejects challenges outside the selected trait" do
    user = User.create!
    weekly = WeeklyProgress.create!(user: user, week_no: 1, start_at: Date.current)
    selected_trait = Trait.find_or_create_by!(code: "C") do |record|
      record.name_ja = "誠実性"
      record.name_en = "Conscientiousness"
    end
    other_trait = Trait.find_or_create_by!(code: "E") do |record|
      record.name_ja = "外向性"
      record.name_en = "Extraversion"
    end
    other_challenge = Challenge.create!(trait: other_trait, title: "人に話しかける", difficulty: 1)
    form = DiagnosisForm.create!(name: "challenge_spec")
    result = DiagnosisResult.create!(
      user: user,
      weekly_progress: weekly,
      diagnosis_form: form,
      status: :complete
    )
    DiagnosisCompletion.create!(diagnosis_result: result)

    expect {
      described_class.call(
        user: user,
        weekly: weekly,
        diagnosis_result_id: result.id,
        challenge_ids: [ other_challenge.id ],
        focus_trait_code: selected_trait.code
      )
    }.to raise_error(UserChallenges::Create::ValidationFailed, /属さない/)
  end
end
