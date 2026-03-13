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

ActiveRecord::Schema[8.1].define(version: 2026_03_13_015911) do
  create_table "event_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.integer "position"
    t.decimal "rate", precision: 10, scale: 2
    t.text "requirements"
    t.string "role_name"
    t.time "shift_end"
    t.boolean "shift_end_next_day", default: false, null: false
    t.time "shift_start"
    t.datetime "updated_at", null: false
    t.integer "vacancies"
    t.index ["event_id"], name: "index_event_roles_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "end_time_next_day", default: false, null: false
    t.date "event_date"
    t.date "event_end_date"
    t.time "event_end_time"
    t.string "event_name"
    t.time "event_start_time"
    t.integer "event_type"
    t.boolean "multi_day", default: false, null: false
    t.string "reference_number"
    t.text "rejection_reason"
    t.time "setup_time"
    t.integer "status", default: 0, null: false
    t.boolean "teardown_next_day", default: false, null: false
    t.time "teardown_time"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "venue"
    t.integer "wizard_step", default: 1, null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "approving_manager_id"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "event_roles", "events"
  add_foreign_key "events", "users"
  add_foreign_key "users", "users", column: "approving_manager_id"
end
