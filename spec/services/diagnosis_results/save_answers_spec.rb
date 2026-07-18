# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiagnosisResults::SaveAnswers do
  it "rejects a question that is not assigned to the diagnosis form" do
    trait = Trait.create!(code: "C", name_ja: "誠実性", name_en: "Conscientiousness")
    assigned = Question.create!(trait: trait, body: "assigned", uuid: SecureRandom.uuid, reverse_scored: false)
    outside = Question.create!(trait: trait, body: "outside", uuid: SecureRandom.uuid, reverse_scored: false)
    form = DiagnosisForm.create!(name: "spec_form")
    DiagnosisFormsQuestion.create!(diagnosis_form: form, question: assigned, question_order: 1)
    user = User.create!
    weekly = WeeklyProgress.create!(user: user, week_no: 1, start_at: Date.current)
    result = DiagnosisResult.create!(user: user, weekly_progress: weekly, diagnosis_form: form)

    expect {
      described_class.call(
        result: result,
        answers: [ { question_uuid: outside.uuid, value: 3 } ]
      )
    }.to raise_error(DiagnosisResults::SaveAnswers::UnknownQuestionUuid)

    expect(result.responses).to be_empty
  end
end
