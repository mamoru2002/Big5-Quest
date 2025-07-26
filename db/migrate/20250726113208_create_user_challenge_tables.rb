class CreateUserChallengeTables < ActiveRecord::Migration[7.2]
  def change
    create_table :user_challenges do |t|
      t.references :user,            null: false, foreign_key: true
      t.references :challenge,       null: false, foreign_key: true
      t.references :weekly_progress, null: false, foreign_key: true
      t.integer    :status,          null: false, default: 0   # チャレンジの状態（未着手=0, 実行=1, 期間終了=2）
      t.integer    :exec_count,      null: false, default: 0   # 実行回数
      t.datetime   :first_done_at
      t.timestamps
    end
    add_index :user_challenges,
              [ :user_id, :challenge_id, :weekly_progress_id ],
              unique: true

    create_table :user_challenge_comments do |t|
      t.references :user_challenge, null: false, foreign_key: { on_delete: :cascade }
      t.text       :comment,        null: false
      t.boolean    :is_public,      null: false, default: true
      t.timestamps
    end

    create_table :emotion_tags_user_challenges do |t|
      t.references :user_challenge, null: false, foreign_key: { on_delete: :cascade }
      t.references :emotion_tag,    null: false, foreign_key: true
      t.timestamps
    end

    create_table :likes do |t|
      t.references :user,           null: false, foreign_key: true
      t.references :user_challenge, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
    add_index :likes, [ :user_id, :user_challenge_id ], unique: true
  end
end
