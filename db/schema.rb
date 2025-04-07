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

ActiveRecord::Schema[8.0].define(version: 2025_04_07_153042) do
  create_table "hrm_data_points", force: :cascade do |t|
    t.integer "hrm_session_id", null: false
    t.integer "beats_per_minute"
    t.datetime "reading_start_time"
    t.datetime "reading_end_time"
    t.integer "duration_in_secs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hrm_session_id", "reading_start_time"], name: "index_hrm_data_points_on_session_and_start_time", unique: true
    t.index ["hrm_session_id"], name: "index_hrm_data_points_on_hrm_session_id"
  end

  create_table "hrm_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "duration_in_secs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_hrm_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "gender"
    t.integer "age"
    t.integer "hr_zone1_bpm_min"
    t.integer "hr_zone1_bpm_max"
    t.integer "hr_zone2_bpm_min"
    t.integer "hr_zone2_bpm_max"
    t.integer "hr_zone3_bpm_min"
    t.integer "hr_zone3_bpm_max"
    t.integer "hr_zone4_bpm_min"
    t.integer "hr_zone4_bpm_max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "hrm_data_points", "hrm_sessions"
  add_foreign_key "hrm_sessions", "users"
end
