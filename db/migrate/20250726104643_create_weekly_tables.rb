class CreateWeeklyTables < ActiveRecord::Migration[7.2]
  def change
    create_table :weekly_progresses do |t|
      t.references :user, foreign_key: true, null: false
      t.integer :week_no, null: false
      t.date :start_at, null: false
      t.timestamps
    end
        add_index :weekly_progresses, [ :user_id, :week_no ], unique: true

    create_table :weekly_status_events do |t|
      t.references :weekly_progress, foreign_key: true, null: false
      t.integer :event_type, null: false  # 0=missed, 1=pause
      t.timestamps
    end
  end
end
