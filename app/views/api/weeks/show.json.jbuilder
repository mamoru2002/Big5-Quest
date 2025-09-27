json.week_no  @weekly.week_no
json.start_at @weekly.start_at
json.end_at   @weekly.start_at + 6
json.editable @editable
json.result_id @result_id

json.challenges do
  json.array! @list do |uc|
    json.id         uc.id
    json.status     uc.status
    json.exec_count uc.exec_count
    json.challenge do
      json.id         uc.challenge_id
      json.title      uc.challenge.title
      json.difficulty uc.challenge.difficulty
    end
  end
end
