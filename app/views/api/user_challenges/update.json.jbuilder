json.id         @user_challenge.id
json.status     @user_challenge.status
json.exec_count @user_challenge.exec_count

json.challenge do
  json.id         @user_challenge.challenge_id
  json.title      @user_challenge.challenge.title
  json.difficulty @user_challenge.challenge.difficulty
end

if (c = @user_challenge.user_challenge_comment)
  json.user_challenge_comment do
    json.id        c.id
    json.comment   c.comment
    json.is_public c.is_public
  end
end

json.emotion_tags_user_challenges(
  @user_challenge.emotion_tags_user_challenges.map { |x| { emotion_tag_id: x.emotion_tag_id } }
)
