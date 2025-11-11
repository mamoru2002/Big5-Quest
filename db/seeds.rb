require 'json'

puts 'Seeding traits ...'
[
  [ 'O', '開放性',    'Openness' ],
  [ 'C', '誠実性',    'Conscientiousness' ],
  [ 'E', '外向性',    'Extraversion' ],
  [ 'A', '協調性',    'Agreeableness' ],
  [ 'N', '情緒安定性', 'Neuroticism' ]
].each do |code, ja, en|
  Trait.find_or_create_by!(code: code) do |t|
    t.name_ja = ja
    t.name_en = en
    puts "  ✔️ Trait #{code}"
  end
end

puts 'Seeding questions ...'
questions_file = Rails.root.join('db/seeds/questions_master.json')
questions_data = JSON.parse(File.read(questions_file), symbolize_names: true)
questions_data.each do |q|
  trait = Trait.find_by!(code: q[:domain])
  Question.find_or_create_by!(uuid: q[:id]) do |qq|
    qq.body           = q[:text]
    qq.trait          = trait
    qq.reverse_scored = (q[:keyed] == 'minus')
    puts "  ✔️ Question #{q[:id]}"
  end
end

def seed_form(name, uuids)
  form = DiagnosisForm.find_or_create_by!(name: name)
  puts "  ✔️ Form: #{form.name} (id=#{form.id})"

  uuids.each_with_index do |uuid, idx|
    question = Question.find_by!(uuid: uuid)
    link = DiagnosisFormsQuestion.find_or_create_by!(
      diagnosis_form: form,
      question:       question
    ) do |dfq|
      dfq.question_order = idx + 1
    end
    puts "     ‣ #{question.uuid} → order=#{link.question_order}"
  end
end

def flatten_forms_map(data, prefix)
  case data
  when Array
    [ [ prefix, data ] ]
  when Hash
    data.flat_map do |key, value|
      flatten_forms_map(value, "#{prefix}_#{key.downcase}")
    end
  else
    []
  end
end

puts 'Seeding forms_map ...'
forms_file = Rails.root.join('db/seeds/forms_map.json')
abort "#{forms_file} not found" unless File.exist?(forms_file)
forms_map_raw = JSON.parse(File.read(forms_file))
puts "Keys: #{forms_map_raw.keys.inspect}"

forms_map_raw.each do |form_name, payload|
  flatten_forms_map(payload, form_name).each do |flat_name, uuids|
    seed_form(flat_name, uuids)
  end
end

puts 'Seeding challenges ...'
Dir.glob(Rails.root.join('db/seeds/challenges_*.json')).sort.each do |path|
  code = File.basename(path).match(/challenges_([A-Z])\.json/)&.captures&.first
  unless code
    warn "Skip #{path} (traitsコードを抽出できません)"
    next
  end

  trait = Trait.find_by!(code: code)
  items = JSON.parse(File.read(path), symbolize_names: true)

  items.each_with_index do |item, idx|
    ch = Challenge.find_or_initialize_by(trait: trait, title: item[:title])
    ch.difficulty = item[:difficulty]
    ch.save!
    puts "Challenge(#{code}) #{idx + 1}/#{items.size}: #{ch.title} (diff=#{ch.difficulty})"
  end
end
puts 'Seeding emotion_tags ...'

EMOTION_TAGS = [
  [ 'achieved',    '達成感' ],
  [ 'fun',         '楽しい' ],
  [ 'insight',     '気づき' ],
  [ 'keep_going',  '続けたい' ],
  [ 'nervous',     '緊張' ],
  [ 'tired',       '疲れ' ]
]

EMOTION_TAGS.each_with_index do |(en, ja), i|
  tag = EmotionTag.find_or_initialize_by(name_en: en)
  tag.name_ja = ja
  tag.save!
  puts "  ✔️ EmotionTag #{i + 1}: #{ja} / #{en} (id=#{tag.id})"
end
