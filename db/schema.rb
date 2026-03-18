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

ActiveRecord::Schema[8.1].define(version: 2026_03_18_015106) do
  create_table "agencies", force: :cascade do |t|
    t.string "contact_email", null: false
    t.datetime "created_at", null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_sent_at"
    t.string "invitation_token", null: false
    t.integer "invited_by_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["contact_email"], name: "index_agencies_on_contact_email", unique: true
    t.index ["invitation_token"], name: "index_agencies_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_agencies_on_invited_by_id"
  end

  create_table "agency_connections", force: :cascade do |t|
    t.integer "agency_id", null: false
    t.datetime "confirmed_at"
    t.integer "confirmed_by_id"
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_agency_connections_on_agency_id"
    t.index ["agency_id"], name: "index_agency_connections_on_agency_id_unique", unique: true
    t.index ["confirmed_by_id"], name: "index_agency_connections_on_confirmed_by_id"
  end

  create_table "agency_staff_member_roles", force: :cascade do |t|
    t.integer "agency_staff_member_id", null: false
    t.datetime "created_at", null: false
    t.integer "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_staff_member_id", "role_id"], name: "idx_on_agency_staff_member_id_role_id_befb0fc7b6", unique: true
    t.index ["agency_staff_member_id"], name: "index_agency_staff_member_roles_on_agency_staff_member_id"
    t.index ["role_id"], name: "index_agency_staff_member_roles_on_role_id"
  end

  create_table "agency_staff_members", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "agency_id", null: false
    t.text "blacklist_reason"
    t.boolean "blacklisted", default: false, null: false
    t.datetime "blacklisted_at"
    t.integer "blacklisted_by_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "gender"
    t.string "mobile"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id", "email"], name: "index_agency_staff_members_on_agency_id_and_email", unique: true
    t.index ["agency_id"], name: "index_agency_staff_members_on_agency_id"
  end

  create_table "agency_staffing_candidates", force: :cascade do |t|
    t.datetime "accepted_at"
    t.integer "agency_staff_member_id", null: false
    t.integer "agency_staffing_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "rejected_at"
    t.text "rejection_reason"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["agency_staff_member_id"], name: "index_agency_staffing_candidates_on_agency_staff_member_id"
    t.index ["agency_staffing_request_id", "agency_staff_member_id"], name: "idx_on_agency_staffing_request_id_agency_staff_memb_6ef8e1834a", unique: true
    t.index ["agency_staffing_request_id"], name: "index_agency_staffing_candidates_on_agency_staffing_request_id"
  end

  create_table "agency_staffing_requests", force: :cascade do |t|
    t.integer "agency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "declined_at"
    t.text "declined_reason"
    t.integer "event_role_id", null: false
    t.text "notes"
    t.integer "requested_by_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "submitted_at"
    t.datetime "updated_at", null: false
    t.integer "vacancies_requested", null: false
    t.index ["agency_id"], name: "index_agency_staffing_requests_on_agency_id"
    t.index ["event_role_id", "agency_id"], name: "index_agency_staffing_requests_on_event_role_id_and_agency_id", unique: true
    t.index ["event_role_id"], name: "index_agency_staffing_requests_on_event_role_id"
    t.index ["requested_by_id"], name: "index_agency_staffing_requests_on_requested_by_id"
  end

  create_table "event_invitations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_role_id", null: false
    t.datetime "responded_at"
    t.integer "staff_member_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["event_role_id", "staff_member_id"], name: "index_event_invitations_on_event_role_id_and_staff_member_id", unique: true
    t.index ["event_role_id"], name: "index_event_invitations_on_event_role_id"
    t.index ["staff_member_id"], name: "index_event_invitations_on_staff_member_id"
  end

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

  create_table "staff_member_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "role_id", null: false
    t.integer "staff_member_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_member_id", "role_id"], name: "index_staff_member_roles_on_staff_member_id_and_role_id", unique: true
  end

  create_table "staff_members", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "blacklist_reason"
    t.boolean "blacklisted", default: false, null: false
    t.datetime "blacklisted_at"
    t.integer "blacklisted_by_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "gender"
    t.string "mobile"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["email"], name: "index_staff_members_on_email", unique: true
    t.index ["user_id"], name: "index_staff_members_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.integer "agency_id"
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
    t.index ["agency_id"], name: "index_users_on_agency_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "agencies", "users", column: "invited_by_id"
  add_foreign_key "agency_connections", "agencies"
  add_foreign_key "agency_connections", "users", column: "confirmed_by_id"
  add_foreign_key "agency_staff_member_roles", "agency_staff_members"
  add_foreign_key "agency_staff_member_roles", "roles"
  add_foreign_key "agency_staff_members", "agencies"
  add_foreign_key "agency_staffing_candidates", "agency_staff_members"
  add_foreign_key "agency_staffing_candidates", "agency_staffing_requests"
  add_foreign_key "agency_staffing_requests", "agencies"
  add_foreign_key "agency_staffing_requests", "event_roles"
  add_foreign_key "agency_staffing_requests", "users", column: "requested_by_id"
  add_foreign_key "event_invitations", "event_roles"
  add_foreign_key "event_invitations", "staff_members"
  add_foreign_key "event_roles", "events"
  add_foreign_key "events", "users"
  add_foreign_key "staff_member_roles", "roles"
  add_foreign_key "staff_member_roles", "staff_members"
  add_foreign_key "staff_members", "users"
  add_foreign_key "staff_members", "users", column: "blacklisted_by_id"
  add_foreign_key "users", "agencies"
  add_foreign_key "users", "users", column: "approving_manager_id"
end
