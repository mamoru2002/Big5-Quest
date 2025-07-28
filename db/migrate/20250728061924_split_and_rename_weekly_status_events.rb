class SplitAndRenameWeeklyStatusEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :weekly_misses do |t|
      t.references :weekly_progress, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    create_table :weekly_pauses do |t|
      t.references :weekly_progress, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
          INSERT INTO weekly_misses (weekly_progress_id, created_at, updated_at)
          SELECT weekly_progress_id, created_at, updated_at
          FROM   weekly_status_events
          WHERE  event_type = 0;
        SQL

        execute <<~SQL
          INSERT INTO weekly_pauses (weekly_progress_id, created_at, updated_at)
          SELECT weekly_progress_id, created_at, updated_at
          FROM   weekly_status_events
          WHERE  event_type = 1;
        SQL
      end
    end

    drop_table :weekly_status_events
  end
end
