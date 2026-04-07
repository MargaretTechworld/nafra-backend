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

ActiveRecord::Schema[7.1].define(version: 2026_02_16_142500) do
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
    t.index ["name", "district_id"], name: "index_chiefdoms_on_name_and_district_id", unique: true
  end

  create_table "contact_people", force: :cascade do |t|
    t.bigint "dealer_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "email"
    t.string "role"
    t.boolean "is_primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dealer_id"], name: "index_contact_people_on_dealer_id"
  end

  create_table "dealers", force: :cascade do |t|
    t.string "name", null: false
    t.string "license_number"
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.string "category_type"
    t.text "head_office_address"
    t.string "ceo_name"
    t.date "registration_date"
    t.date "license_expiry_date"
    t.string "licensing_status", default: "Not Licensed"
    t.index ["name"], name: "index_dealers_on_name", unique: true
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.index ["name"], name: "index_districts_on_name", unique: true
    t.index ["region_id"], name: "index_districts_on_region_id"
  end

  create_table "draft_chiefdoms", force: :cascade do |t|
    t.bigint "draft_district_id", null: false
    t.bigint "chiefdom_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chiefdom_id"], name: "index_draft_chiefdoms_on_chiefdom_id"
    t.index ["draft_district_id", "chiefdom_id"], name: "idx_draft_chiefdoms_district_chiefdom"
    t.index ["draft_district_id", "name"], name: "index_draft_chiefdoms_on_draft_district_id_and_name"
    t.index ["draft_district_id"], name: "idx_draft_chiefdoms_district_id"
    t.index ["draft_district_id"], name: "index_draft_chiefdoms_on_draft_district_id"
  end

  create_table "draft_districts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "agency_id", null: false
    t.string "name", null: false
    t.json "data"
    t.datetime "last_saved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
    t.bigint "submitted_by_id"
    t.bigint "locked_by_id"
    t.datetime "locked_at"
    t.datetime "lock_expires_at"
    t.index ["agency_id", "updated_at"], name: "idx_draft_districts_agency_updated_at"
    t.index ["agency_id"], name: "index_draft_districts_on_agency_id"
    t.index ["last_saved_at"], name: "index_draft_districts_on_last_saved_at"
    t.index ["locked_by_id"], name: "index_draft_districts_on_locked_by_id"
    t.index ["submitted_by_id"], name: "index_draft_districts_on_submitted_by_id"
    t.index ["updated_at"], name: "index_draft_districts_on_updated_at"
    t.index ["user_id", "agency_id", "last_saved_at"], name: "idx_draft_districts_user_agency_saved_at"
    t.index ["user_id", "agency_id", "name"], name: "idx_draft_districts_user_agency_name_unique", unique: true
    t.index ["user_id", "agency_id", "name"], name: "index_draft_districts_on_user_agency_name", unique: true
    t.index ["user_id", "agency_id"], name: "index_draft_districts_on_user_id_and_agency_id"
    t.index ["user_id"], name: "index_draft_districts_on_user_id"
  end

  create_table "draft_fertilizers", force: :cascade do |t|
    t.bigint "draft_chiefdom_id", null: false
    t.bigint "fertilizer_id"
    t.bigint "dealer_id"
    t.integer "bags_25kg", default: 0
    t.integer "bags_50kg", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dealer_id"], name: "index_draft_fertilizers_on_dealer_id"
    t.index ["draft_chiefdom_id", "fertilizer_id", "dealer_id"], name: "index_draft_fertilizers_on_chiefdom_fertilizer_dealer", unique: true
    t.index ["draft_chiefdom_id", "fertilizer_id"], name: "idx_draft_fertilizers_chiefdom_fertilizer"
    t.index ["draft_chiefdom_id"], name: "idx_draft_fertilizers_chiefdom_id"
    t.index ["draft_chiefdom_id"], name: "index_draft_fertilizers_on_draft_chiefdom_id"
    t.index ["fertilizer_id", "dealer_id"], name: "idx_draft_fertilizers_fertilizer_dealer"
    t.index ["fertilizer_id"], name: "index_draft_fertilizers_on_fertilizer_id"
  end

  create_table "drafts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "data"
    t.string "status"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_drafts_on_user_id"
  end

  create_table "fertilizers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_fertilizers_on_name", unique: true
  end

  create_table "outlets", force: :cascade do |t|
    t.bigint "dealer_id", null: false
    t.text "address", null: false
    t.bigint "region_id", null: false
    t.bigint "district_id", null: false
    t.bigint "chiefdom_id", null: false
    t.bigint "township_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chiefdom_id"], name: "index_outlets_on_chiefdom_id"
    t.index ["dealer_id"], name: "index_outlets_on_dealer_id"
    t.index ["district_id"], name: "index_outlets_on_district_id"
    t.index ["region_id"], name: "index_outlets_on_region_id"
    t.index ["township_id"], name: "index_outlets_on_township_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_regions_on_name", unique: true
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
    t.bigint "draft_id"
    t.index ["agency_id"], name: "index_submissions_on_agency_id"
    t.index ["draft_id"], name: "index_submissions_on_draft_id"
    t.index ["submitted_by_id"], name: "index_submissions_on_submitted_by_id"
  end

  create_table "townships", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "chiefdom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chiefdom_id"], name: "index_townships_on_chiefdom_id"
    t.index ["name", "chiefdom_id"], name: "index_townships_on_name_and_chiefdom_id", unique: true
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
  add_foreign_key "contact_people", "dealers"
  add_foreign_key "districts", "regions"
  add_foreign_key "draft_chiefdoms", "chiefdoms"
  add_foreign_key "draft_chiefdoms", "draft_districts"
  add_foreign_key "draft_districts", "agencies"
  add_foreign_key "draft_districts", "users"
  add_foreign_key "draft_districts", "users", column: "locked_by_id"
  add_foreign_key "draft_districts", "users", column: "submitted_by_id"
  add_foreign_key "draft_fertilizers", "dealers"
  add_foreign_key "draft_fertilizers", "draft_chiefdoms"
  add_foreign_key "draft_fertilizers", "fertilizers"
  add_foreign_key "drafts", "users"
  add_foreign_key "outlets", "chiefdoms"
  add_foreign_key "outlets", "dealers"
  add_foreign_key "outlets", "districts"
  add_foreign_key "outlets", "regions"
  add_foreign_key "outlets", "townships"
  add_foreign_key "submission_items", "chiefdoms"
  add_foreign_key "submission_items", "dealers"
  add_foreign_key "submission_items", "districts"
  add_foreign_key "submission_items", "fertilizers"
  add_foreign_key "submission_items", "submissions"
  add_foreign_key "submissions", "agencies"
  add_foreign_key "submissions", "drafts"
  add_foreign_key "submissions", "users", column: "submitted_by_id"
  add_foreign_key "townships", "chiefdoms"
end
