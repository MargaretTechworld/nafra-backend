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

ActiveRecord::Schema[7.1].define(version: 2026_01_25_132348) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "project_name", null: false
    t.string "ministry", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_agencies_on_name", unique: true
    t.index ["user_id"], name: "index_agencies_on_user_id"
  end

  create_table "chiefdoms", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "district_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id"], name: "index_chiefdoms_on_district_id"
    t.index ["name"], name: "index_chiefdoms_on_name", unique: true
  end

  create_table "dealers", force: :cascade do |t|
    t.string "name", null: false
    t.string "license_number"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dealers_on_name", unique: true
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_districts_on_name", unique: true
  end

  create_table "fertilizers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_fertilizers_on_name", unique: true
  end

  create_table "submission_items", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.bigint "district_id", null: false
    t.bigint "chiefdom_id", null: false
    t.bigint "fertilizer_id", null: false
    t.bigint "dealer_id", null: false
    t.integer "bags_25kg", null: false
    t.integer "bags_50kg", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chiefdom_id"], name: "index_submission_items_on_chiefdom_id"
    t.index ["dealer_id"], name: "index_submission_items_on_dealer_id"
    t.index ["district_id"], name: "index_submission_items_on_district_id"
    t.index ["fertilizer_id"], name: "index_submission_items_on_fertilizer_id"
    t.index ["submission_id", "district_id"], name: "index_submission_items_on_submission_id_and_district_id"
    t.index ["submission_id", "fertilizer_id"], name: "index_submission_items_on_submission_id_and_fertilizer_id"
    t.index ["submission_id"], name: "index_submission_items_on_submission_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "agency_id", null: false
    t.bigint "submitted_by_id", null: false
    t.date "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_submissions_on_agency_id"
    t.index ["submitted_by_id"], name: "index_submissions_on_submitted_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "agency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "agencies", "users"
  add_foreign_key "chiefdoms", "districts"
  add_foreign_key "submission_items", "chiefdoms"
  add_foreign_key "submission_items", "dealers"
  add_foreign_key "submission_items", "districts"
  add_foreign_key "submission_items", "fertilizers"
  add_foreign_key "submission_items", "submissions"
  add_foreign_key "submissions", "agencies"
  add_foreign_key "submissions", "users", column: "submitted_by_id"
end
