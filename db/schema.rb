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

ActiveRecord::Schema[7.1].define(version: 2026_03_14_164113) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.float "glassdoor_rating"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_applications", force: :cascade do |t|
    t.bigint "job_posting_id", null: false
    t.string "status"
    t.datetime "applied_at"
    t.datetime "follow_up_due_at"
    t.datetime "last_contact_at"
    t.string "contact_name"
    t.string "contact_email"
    t.text "notes"
    t.string "resume_version"
    t.string "cover_letter_version"
    t.text "outcome_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_posting_id"], name: "index_job_applications_on_job_posting_id"
  end

  create_table "job_postings", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "search_profile_id", null: false
    t.string "title"
    t.boolean "remote"
    t.string "apply_url"
    t.text "description"
    t.datetime "posted_at"
    t.datetime "scraped_at"
    t.string "status"
    t.integer "ai_score"
    t.text "ai_reason"
    t.integer "friction_score"
    t.boolean "excluded"
    t.string "excluded_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_job_postings_on_company_id"
    t.index ["search_profile_id"], name: "index_job_postings_on_search_profile_id"
  end

  create_table "search_profiles", force: :cascade do |t|
    t.string "name"
    t.text "target_titles"
    t.text "target_skills"
    t.text "keywords"
    t.text "negative_keywords"
    t.text "excluded_titles"
    t.text "excluded_sources"
    t.boolean "remote_only"
    t.text "allowed_locations"
    t.float "minimum_rating"
    t.boolean "exclude_workday"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "job_applications", "job_postings"
  add_foreign_key "job_postings", "companies"
  add_foreign_key "job_postings", "search_profiles"
end
