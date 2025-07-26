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
forms_map  = JSON.parse(File.read(forms_file))  # 今回は key が文字列のまま

# 各フォームについて繰り返す
forms_map.each do |form_name, question_ids|
  # すでにフォームが存在していれば取得、なければ新規作成
  form = DiagnosisForm.find_by(name: form_name)
  unless form
    form = DiagnosisForm.create!(name: form_name)
  end

  # このフォームに紐づく質問IDのリストを順番に処理
  question_ids.each_with_index do |uuid, index|
    # 質問をUUIDから探す（なければエラー）
    question = Question.find_by!(uuid: uuid)

    # フォームと質問の紐付け
    link = DiagnosisFormsQuestion.find_by(
      diagnosis_form: form,
      question:       question
    )

    # なければ作成する（question_order は順番を示す数値）
    unless link
      DiagnosisFormsQuestion.create!(
        diagnosis_form: form,
        question:       question,
        question_order: index + 1  # 1から始まる連番にする
      )
    end
  end
end
