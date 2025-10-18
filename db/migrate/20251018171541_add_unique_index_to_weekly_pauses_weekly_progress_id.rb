# frozen_string_literal: true

class AddUniqueIndexToWeeklyPausesWeeklyProgressId < ActiveRecord::Migration[8.0]
  def up
    # 1) 先にFKを外す（これがインデックスに依存しているため）
    if foreign_key_exists?(:weekly_pauses, :weekly_progresses)
      remove_foreign_key :weekly_pauses, :weekly_progresses
    end

    # 2) 既存の非ユニークインデックスを削除
    if index_exists?(:weekly_pauses, :weekly_progress_id, name: "index_weekly_pauses_on_weekly_progress_id")
      remove_index :weekly_pauses, name: "index_weekly_pauses_on_weekly_progress_id"
    end

    # 3) ユニークで作り直す（同名でOK）
    add_index :weekly_pauses, :weekly_progress_id,
              unique: true,
              name: "index_weekly_pauses_on_weekly_progress_id"

    # 4) FKを戻す（on_delete等はschema準拠で指定なし）
    add_foreign_key :weekly_pauses, :weekly_progresses, column: :weekly_progress_id
  end

  def down
    # 逆順：FK外す → ユニークindex外す → 非ユニークindex復旧 → FK戻す
    if foreign_key_exists?(:weekly_pauses, :weekly_progresses)
      remove_foreign_key :weekly_pauses, :weekly_progresses
    end

    if index_exists?(:weekly_pauses, :weekly_progress_id, name: "index_weekly_pauses_on_weekly_progress_id")
      remove_index :weekly_pauses, name: "index_weekly_pauses_on_weekly_progress_id"
    end

    add_index :weekly_pauses, :weekly_progress_id,
              name: "index_weekly_pauses_on_weekly_progress_id"

    add_foreign_key :weekly_pauses, :weekly_progresses, column: :weekly_progress_id
  end
end