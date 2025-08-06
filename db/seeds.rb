# db/seeds.rb

require 'json'

puts 'Seeding traits ...'
[
  [ 'O', '開放性',    'Openness' ],
  [ 'C', '誠実性',    'Conscientiousness' ],
  [ 'E', '外交性',    'Extraversion' ],
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

# ───────────────────────────────────────────
# フォーム登録ヘルパー
# ───────────────────────────────────────────
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

# ネストされた forms_map を平坦化するメソッド
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
abort "⚠️ #{forms_file} not found" unless File.exist?(forms_file)
forms_map_raw = JSON.parse(File.read(forms_file))
puts "  ▶️ Keys: #{forms_map_raw.keys.inspect}"

forms_map_raw.each do |form_name, payload|
  flatten_forms_map(payload, form_name).each do |flat_name, uuids|
    seed_form(flat_name, uuids)
  end
end

puts 'Seeding challenges ...'
challenges_path = Rails.root.join('db/seeds/challenges_C.json')
challenge_items = JSON.parse(File.read(challenges_path), symbolize_names: true)
conscientious = Trait.find_by!(code: 'C')
challenge_items.each do |item|
  Challenge.find_or_create_by!(
    trait:      conscientious,
    title:      item[:title],
    difficulty: item[:difficulty]
  )
  puts "  ✔️ Challenge #{item[:title]}"
end

puts '✅ Seeding complete.'
