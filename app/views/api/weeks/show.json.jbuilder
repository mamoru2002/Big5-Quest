json.week_no   @weekly.week_no
json.start_at  @weekly.start_at
json.end_at    @weekly.start_at + 6
json.editable  @editable
json.result_id @result_id
json.diagnosis_status @diagnosis_status
json.diagnosis_completed (@diagnosis_status == 'complete')
json.paused @paused_this_week
json.program_week @program_week
json.is_milestone_26 @is_milestone_26
json.milestone_bucket @milestone_bucket
json.is_final_full50 @is_final_full50
json.rotation_bucket @rotation_bucket
json.focus_trait_code @focus_trait_code

json.challenges do
  json.array! @list do |user_challenge|
    json.id         user_challenge.id
    json.status     user_challenge.status
    json.exec_count user_challenge.exec_count
    json.challenge do
      json.id         user_challenge.challenge_id
      json.title      user_challenge.challenge.title
      json.difficulty user_challenge.challenge.difficulty
    end
  end
end
