json.id         user_challenge.id
json.status     user_challenge.status
json.exec_count user_challenge.exec_count

json.challenge do
  json.id         user_challenge.challenge_id
  json.title      user_challenge.challenge.title
  json.difficulty user_challenge.challenge.difficulty
end
