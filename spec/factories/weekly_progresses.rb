FactoryBot.define do
  factory :weekly_progress do
    association :user
    sequence(:week_no) { |n| n }
    start_at { Date.today.beginning_of_week }
  end
end
