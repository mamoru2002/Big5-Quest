# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiagnosisResults::Complete do
  let(:trait_record) do
    Trait.find_or_create_by!(code: "E") do |record|
      record.name_ja = "外向性"
      record.name_en = "Extraversion"
    end
  end
  let(:questions) do
    2.times.map do |index|
      Question.create!(
        trait: trait_record,
        body: "question #{index}",
        uuid: SecureRandom.uuid,
        reverse_scored: false
      )
    end
  end
  let(:form) do
    DiagnosisForm.create!(name: "complete_spec").tap do |record|
      questions.each_with_index do |question, index|
        DiagnosisFormsQuestion.create!(
          diagnosis_form: record,
          question: question,
          question_order: index + 1
        )
      end
    end
  end
  let(:user) { User.create! }
  let(:weekly) { WeeklyProgress.create!(user: user, week_no: 1, start_at: Date.current) }
  let(:result) do
    DiagnosisResult.create!(user: user, weekly_progress: weekly, diagnosis_form: form)
  end

  it "does not complete a diagnosis with missing answers" do
    Response.create!(diagnosis_result: result, question: questions.first, value: 3)

    expect { described_class.call(result: result) }
      .to raise_error(DiagnosisResults::Complete::IncompleteAnswers)

    expect(result.reload).to be_incomplete
    expect(result.diagnosis_completion).to be_nil
  end

  it "completes a diagnosis exactly once after all questions are answered" do
    questions.each { |question| Response.create!(diagnosis_result: result, question: question, value: 4) }

    expect { described_class.call(result: result) }
      .to change(DiagnosisCompletion, :count).by(1)
    expect { described_class.call(result: result) }
      .not_to change(DiagnosisCompletion, :count)

    expect(result.reload).to be_complete
  end
end
