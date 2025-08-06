# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'json'

puts 'Seeding traits ...'

traits_list = [
  [ 'O', '開放性',    'Openness' ],
  [ 'C', '誠実性',    'Conscientiousness' ],
  [ 'E', '外交性',    'Extraversion' ],
  [ 'A', '協調性',    'Agreeableness' ],
  [ 'N', '情緒安定性', 'Neuroticism' ]
]

traits_list.each do |code, ja, en|
  trait = Trait.find_by(code: code)

  unless trait
    Trait.create!(
      code:    code,
      name_ja: ja,
      name_en: en
    )
    puts "Trait #{code} created"
  end
end

questions_file = Rails.root.join('db/seeds/questions_master.json')

# ファイルを読み込んで、JSONをRubyの配列に変換する（キーはシンボル形式に）
questions_json = JSON.parse(File.read(questions_file), symbolize_names: true)

# 各質問データを1つずつ処理
questions_json.each do |q|
  # 質問が対応する性格特性（O, C, E, A, N）を Trait テーブルから探す
  trait = Trait.find_by!(code: q[:domain])

  # uuid が一致する質問がすでにあるか確認
  question = Question.find_by(uuid: q[:id])

  # なければ新しく作成する
  unless question
    Question.create!(
      uuid:           q[:id],                      # 質問の一意なID
      body:           q[:text],                    # 質問文
      trait:          trait,                       # 対応する特性
      reverse_scored: (q[:keyed] == 'minus')       # スコア反転するか？
    )
    puts "Question #{q[:id]} created"
  end
end

# フォームと質問の対応づけを登録

forms_file = Rails.root.join('db/seeds/forms_map.json')
unless File.exist?(forms_file)
  puts "⚠️ forms_map.json が見つかりません: #{forms_file}"
  exit(1)
end

raw = File.read(forms_file)
begin
  forms_map = JSON.parse(raw)
rescue JSON::ParserError => e
  puts "⚠️ forms_map.json のパースに失敗しました: #{e.message}"
  exit(1)
end

puts "🔍 フォーム登録用 JSON キー一覧: #{forms_map.keys.inspect}"

forms_map.each do |form_name, question_ids|
  form = DiagnosisForm.find_or_create_by!(name: form_name)
  puts "  ✔️ フォーム登録: #{form.name} (id=#{form.id})"

  question_ids.each_with_index do |uuid, index|
    # 質問がないときはエラー
    question = Question.find_by!(uuid: uuid)
    link = DiagnosisFormsQuestion.find_or_create_by!(
      diagnosis_form: form,
      question:       question
    ) do |dfq|
      dfq.question_order = index + 1
    end
    puts "    ‣ link #{question.uuid} を order=#{link.question_order} で登録"
  end
end

challenges_path = Rails.root.join('db/seeds/challenges_C.json')
challenge_items = JSON.parse(File.read(challenges_path), symbolize_names: true)

conscientious = Trait.find_by!(code: 'C')  # 誠実性を取得

challenge_items.each do |item|
  Challenge.find_or_create_by!(
    trait:      conscientious,
    title:      item[:title],
    difficulty: item[:difficulty]
  )
end
