class CreateDiagnosisTables < ActiveRecord::Migration[7.2]
  def change
    create_table :diagnosis_results do |t|
      t.references :user,              null: false, foreign_key: true
      t.references :diagnosis_form,    null: false, foreign_key: true
      t.references :weekly_progress,   null: false, foreign_key: true
      t.integer    :status,            null: false, default: 0
      t.timestamps
    end
    add_index :diagnosis_results, [ :user_id, :weekly_progress_id ], unique: true

    create_table :responses do |t|
      t.references :diagnosis_result, null: false, foreign_key: true
      t.references :question,         null: false, foreign_key: true
      t.integer    :value,            null: false   # 1〜5
      t.timestamps
    end

    create_table :diagnosis_starts do |t|
      t.references :diagnosis_result, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps                    # created_at が開始時刻
    end

    create_table :diagnosis_completions do |t|
      t.references :diagnosis_result, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps                    # created_at が完了時刻
    end
  end
end
