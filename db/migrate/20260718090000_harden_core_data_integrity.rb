# frozen_string_literal: true

require "securerandom"

class HardenCoreDataIntegrity < ActiveRecord::Migration[8.0]
  def up
    backfill_completed_challenges
    normalize_question_uuids
    remove_duplicate_rows
    add_unique_indexes
    add_value_constraints
  end

  def down
    remove_check_constraint :responses, name: "responses_value_between_1_and_5", if_exists: true
    remove_check_constraint :user_challenges, name: "user_challenges_exec_count_non_negative", if_exists: true

    remove_index :questions, name: "index_questions_on_uuid", if_exists: true
    add_index :questions, :uuid, name: "index_questions_on_uuid"

    remove_index :responses, name: "idx_responses_result_question", if_exists: true
    add_index :diagnosis_starts, :diagnosis_result_id, name: "index_diagnosis_starts_on_diagnosis_result_id"
    remove_index :diagnosis_starts, name: "idx_diagnosis_starts_result", if_exists: true
    add_index :diagnosis_completions, :diagnosis_result_id, name: "index_diagnosis_completions_on_diagnosis_result_id"
    remove_index :diagnosis_completions, name: "idx_diagnosis_completions_result", if_exists: true
    add_index :user_challenge_comments, :user_challenge_id, name: "index_user_challenge_comments_on_user_challenge_id"
    remove_index :user_challenge_comments, name: "idx_user_challenge_comments_challenge", if_exists: true
    remove_index :emotion_tags_user_challenges, name: "idx_emotion_tags_user_challenges_unique", if_exists: true
    add_index :weekly_misses, :weekly_progress_id, name: "index_weekly_misses_on_weekly_progress_id"
    remove_index :weekly_misses, name: "idx_weekly_misses_progress", if_exists: true

    change_column_null :questions, :uuid, true
  end

  private

  def backfill_completed_challenges
    execute <<~SQL.squish
      UPDATE user_challenges
      SET status = 3,
          first_done_at = COALESCE(first_done_at, updated_at)
      WHERE status = 2 AND exec_count > 0
    SQL
  end

  def normalize_question_uuids
    execute "UPDATE questions SET uuid = UUID() WHERE uuid IS NULL OR uuid = ''"

    duplicate_uuids = select_values(<<~SQL.squish)
      SELECT uuid
      FROM questions
      GROUP BY uuid
      HAVING COUNT(*) > 1
    SQL

    duplicate_uuids.each do |uuid|
      ids = select_values(<<~SQL.squish).map(&:to_i)
        SELECT id
        FROM questions
        WHERE uuid = #{connection.quote(uuid)}
        ORDER BY id
      SQL

      ids.drop(1).each do |id|
        execute <<~SQL.squish
          UPDATE questions
          SET uuid = #{connection.quote(SecureRandom.uuid)}
          WHERE id = #{id}
        SQL
      end
    end
  end

  def remove_duplicate_rows
    delete_duplicates(:responses, %i[diagnosis_result_id question_id])
    delete_duplicates(:diagnosis_starts, %i[diagnosis_result_id])
    delete_duplicates(:diagnosis_completions, %i[diagnosis_result_id])
    delete_duplicates(:user_challenge_comments, %i[user_challenge_id])
    delete_duplicates(:emotion_tags_user_challenges, %i[user_challenge_id emotion_tag_id])
    delete_duplicates(:weekly_misses, %i[weekly_progress_id])
  end

  def delete_duplicates(table, columns)
    equality = columns.map { |column| "d.#{column} = k.#{column}" }.join(" AND ")
    execute <<~SQL.squish
      DELETE d
      FROM #{table} AS d
      INNER JOIN #{table} AS k
        ON #{equality}
       AND d.id < k.id
    SQL
  end

  def add_unique_indexes
    change_column_null :questions, :uuid, false
    ensure_unique_index :questions, :uuid, "index_questions_on_uuid"

    ensure_unique_index :responses,
                        %i[diagnosis_result_id question_id],
                        "idx_responses_result_question"
    ensure_unique_index :diagnosis_starts,
                        :diagnosis_result_id,
                        "idx_diagnosis_starts_result"
    remove_index :diagnosis_starts, name: "index_diagnosis_starts_on_diagnosis_result_id", if_exists: true
    ensure_unique_index :diagnosis_completions,
                        :diagnosis_result_id,
                        "idx_diagnosis_completions_result"
    remove_index :diagnosis_completions, name: "index_diagnosis_completions_on_diagnosis_result_id", if_exists: true
    ensure_unique_index :user_challenge_comments,
                        :user_challenge_id,
                        "idx_user_challenge_comments_challenge"
    remove_index :user_challenge_comments, name: "index_user_challenge_comments_on_user_challenge_id", if_exists: true
    ensure_unique_index :emotion_tags_user_challenges,
                        %i[user_challenge_id emotion_tag_id],
                        "idx_emotion_tags_user_challenges_unique"
    ensure_unique_index :weekly_misses,
                        :weekly_progress_id,
                        "idx_weekly_misses_progress"
    remove_index :weekly_misses, name: "index_weekly_misses_on_weekly_progress_id", if_exists: true
  end

  def add_value_constraints
    unless check_constraint_exists?(:responses, name: "responses_value_between_1_and_5")
      add_check_constraint :responses,
                           "value BETWEEN 1 AND 5",
                           name: "responses_value_between_1_and_5"
    end

    return if check_constraint_exists?(:user_challenges, name: "user_challenges_exec_count_non_negative")

    add_check_constraint :user_challenges,
                         "exec_count >= 0",
                         name: "user_challenges_exec_count_non_negative"
  end

  def ensure_unique_index(table, columns, name)
    return if index_exists?(table, columns, unique: true, name: name)

    remove_index table, name: name, if_exists: true
    add_index table, columns, unique: true, name: name
  end
end
