class CreateTraitsEmotionTagsAndForms < ActiveRecord::Migration[7.2]
  def change
    create_table :traits do |t|
      t.string :code,    null: false, limit: 1    # O/C/E/A/N
      t.string :name_ja, null: false, limit: 20
      t.string :name_en, null: false, limit: 20
      t.timestamps
    end
    add_index :traits, :code, unique: true

    create_table :diagnosis_forms do |t|
      t.string :name, null: false, limit: 20
      t.timestamps
    end
    add_index :diagnosis_forms, :name, unique: true

    create_table :questions do |t|
      t.string     :body,           null: false, limit: 200
      t.references :trait,          null: false, foreign_key: true
      t.boolean    :reverse_scored, null: false
      t.timestamps
    end

    create_table :diagnosis_forms_questions do |t|
      t.references :diagnosis_form, null: false, foreign_key: true
      t.references :question,       null: false, foreign_key: true
      t.integer    :question_order, null: false
      t.timestamps
    end
    add_index :diagnosis_forms_questions,
              %i[diagnosis_form_id question_id],
              unique: true

    create_table :challenges do |t|
      t.references :trait,      null: false, foreign_key: true
      t.integer    :difficulty, null: false, limit: 1  # 1–10
      t.string     :title,      null: false, limit: 200
      t.timestamps
    end
    add_index :challenges, :title

    create_table :emotion_tags do |t|
      t.string :name_en, null: false, limit: 20
      t.string :name_ja, null: false, limit: 20
      t.timestamps
    end
  end
end
