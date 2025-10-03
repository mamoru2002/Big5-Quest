json.id         user_challenge.id
json.status     user_challenge.status
json.exec_count user_challenge.exec_count

json.challenge do
  json.id         user_challenge.challenge_id
  json.title      user_challenge.challenge.title
  json.difficulty user_challenge.challenge.difficulty
end

if user_challenge.user_challenge_comment
  json.user_challenge_comment do
    json.id       user_challenge.user_challenge_comment.id
    json.comment  user_challenge.user_challenge_comment.comment
    json.is_public user_challenge.user_challenge_comment.is_public
  end
else
  json.user_challenge_comment nil
end

json.emotion_tags_user_challenges do
  json.array! user_challenge.emotion_tags_user_challenges do |link|
    json.emotion_tag_id link.emotion_tag_id
  end
end
