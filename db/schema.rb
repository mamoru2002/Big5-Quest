# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_07_26_113208) do
  create_table "challenges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "trait_id", null: false
    t.integer "difficulty", limit: 1, null: false
    t.string "title", limit: 200, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_challenges_on_title"
    t.index ["trait_id"], name: "index_challenges_on_trait_id"
  end

  create_table "diagnosis_completions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "diagnosis_result_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosis_result_id"], name: "index_diagnosis_completions_on_diagnosis_result_id"
  end

  create_table "diagnosis_forms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_diagnosis_forms_on_name", unique: true
  end

  create_table "diagnosis_forms_questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "diagnosis_form_id", null: false
    t.bigint "question_id", null: false
    t.integer "question_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosis_form_id", "question_id"], name: "idx_on_diagnosis_form_id_question_id_8d41e138ae", unique: true
    t.index ["diagnosis_form_id"], name: "index_diagnosis_forms_questions_on_diagnosis_form_id"
    t.index ["question_id"], name: "index_diagnosis_forms_questions_on_question_id"
  end

  create_table "diagnosis_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "diagnosis_form_id", null: false
    t.bigint "weekly_progress_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosis_form_id"], name: "index_diagnosis_results_on_diagnosis_form_id"
    t.index ["user_id", "weekly_progress_id"], name: "index_diagnosis_results_on_user_id_and_weekly_progress_id", unique: true
    t.index ["user_id"], name: "index_diagnosis_results_on_user_id"
    t.index ["weekly_progress_id"], name: "index_diagnosis_results_on_weekly_progress_id"
  end

  create_table "diagnosis_starts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "diagnosis_result_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosis_result_id"], name: "index_diagnosis_starts_on_diagnosis_result_id"
  end

  create_table "emotion_tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name_en", limit: 20, null: false
    t.string "name_ja", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emotion_tags_user_challenges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_challenge_id", null: false
    t.bigint "emotion_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emotion_tag_id"], name: "index_emotion_tags_user_challenges_on_emotion_tag_id"
    t.index ["user_challenge_id"], name: "index_emotion_tags_user_challenges_on_user_challenge_id"
  end

  create_table "likes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "user_challenge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_challenge_id"], name: "index_likes_on_user_challenge_id"
    t.index ["user_id", "user_challenge_id"], name: "index_likes_on_user_id_and_user_challenge_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "body", limit: 200, null: false
    t.bigint "trait_id", null: false
    t.boolean "reverse_scored", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["trait_id"], name: "index_questions_on_trait_id"
    t.index ["uuid"], name: "index_questions_on_uuid"
  end

  create_table "responses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "diagnosis_result_id", null: false
    t.bigint "question_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosis_result_id"], name: "index_responses_on_diagnosis_result_id"
    t.index ["question_id"], name: "index_responses_on_question_id"
  end

  create_table "traits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", limit: 1, null: false
    t.string "name_ja", limit: 20, null: false
    t.string "name_en", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_traits_on_code", unique: true
  end

  create_table "user_challenge_comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_challenge_id", null: false
    t.text "comment", null: false
    t.boolean "is_public", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_challenge_id"], name: "index_user_challenge_comments_on_user_challenge_id"
  end

  create_table "user_challenges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "challenge_id", null: false
    t.bigint "weekly_progress_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "exec_count", default: 0, null: false
    t.datetime "first_done_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_user_challenges_on_challenge_id"
    t.index ["user_id", "challenge_id", "weekly_progress_id"], name: "idx_on_user_id_challenge_id_weekly_progress_id_9a16a9f5de", unique: true
    t.index ["user_id"], name: "index_user_challenges_on_user_id"
    t.index ["weekly_progress_id"], name: "index_user_challenges_on_weekly_progress_id"
  end

  create_table "user_credentials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "email", null: false
    t.string "password_hash", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_user_credentials_on_email", unique: true
    t.index ["user_id"], name: "index_user_credentials_on_user_id", unique: true
  end

  create_table "user_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", limit: 50, null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "user_visits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", limit: 64, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_user_visits_on_token", unique: true
    t.index ["user_id"], name: "index_user_visits_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "weekly_progresses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "week_no", null: false
    t.date "start_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "week_no"], name: "index_weekly_progresses_on_user_id_and_week_no", unique: true
    t.index ["user_id"], name: "index_weekly_progresses_on_user_id"
  end

  create_table "weekly_status_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "weekly_progress_id", null: false
    t.integer "event_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["weekly_progress_id"], name: "index_weekly_status_events_on_weekly_progress_id"
  end

  add_foreign_key "challenges", "traits"
  add_foreign_key "diagnosis_completions", "diagnosis_results", on_delete: :cascade
  add_foreign_key "diagnosis_forms_questions", "diagnosis_forms"
  add_foreign_key "diagnosis_forms_questions", "questions"
  add_foreign_key "diagnosis_results", "diagnosis_forms"
  add_foreign_key "diagnosis_results", "users"
  add_foreign_key "diagnosis_results", "weekly_progresses"
  add_foreign_key "diagnosis_starts", "diagnosis_results", on_delete: :cascade
  add_foreign_key "emotion_tags_user_challenges", "emotion_tags"
  add_foreign_key "emotion_tags_user_challenges", "user_challenges", on_delete: :cascade
  add_foreign_key "likes", "user_challenges", on_delete: :cascade
  add_foreign_key "likes", "users"
  add_foreign_key "questions", "traits"
  add_foreign_key "responses", "diagnosis_results"
  add_foreign_key "responses", "questions"
  add_foreign_key "user_challenge_comments", "user_challenges", on_delete: :cascade
  add_foreign_key "user_challenges", "challenges"
  add_foreign_key "user_challenges", "users"
  add_foreign_key "user_challenges", "weekly_progresses"
  add_foreign_key "user_credentials", "users", on_delete: :cascade
  add_foreign_key "user_profiles", "users", on_delete: :cascade
  add_foreign_key "user_visits", "users", on_delete: :cascade
  add_foreign_key "weekly_progresses", "users"
  add_foreign_key "weekly_status_events", "weekly_progresses"
end
