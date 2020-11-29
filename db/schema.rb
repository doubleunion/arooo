# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_24_040111) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "state", null: false
    t.boolean "agreement_terms", default: false, null: false
    t.boolean "agreement_policies", default: false, null: false
    t.boolean "agreement_female", default: false, null: false
    t.datetime "submitted_at"
    t.datetime "processed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "stale_email_sent_at"
    t.index ["state"], name: "index_applications_on_state"
    t.index ["user_id"], name: "index_applications_on_user_id"
  end

  create_table "authentications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "application_id", null: false
    t.string "body", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "configurables", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_configurables_on_name"
  end

  create_table "door_codes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "code", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_door_codes_on_code", unique: true
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "twitter"
    t.string "facebook"
    t.string "website"
    t.string "linkedin"
    t.string "blog"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "show_name_on_site", default: false, null: false
    t.string "gravatar_email"
    t.string "summary", limit: 2000
    t.string "reasons", limit: 2000
    t.string "projects", limit: 2000
    t.string "skills", limit: 2000
    t.string "feminism", limit: 2000
    t.string "pronouns"
    t.string "attendance", limit: 2000
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sponsorships", id: :serial, force: :cascade do |t|
    t.integer "application_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "username"
    t.string "state", null: false
    t.datetime "last_logged_in_at"
    t.string "email_for_google"
    t.integer "dues_pledge"
    t.boolean "is_admin", default: false
    t.boolean "setup_complete"
    t.text "membership_note"
    t.string "stripe_customer_id"
    t.datetime "last_stripe_charge_succeeded"
    t.boolean "is_scholarship", default: false
    t.boolean "voting_policy_agreement", default: false
    t.string "pronounceable_name"
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "application_id", null: false
    t.boolean "value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["application_id"], name: "index_votes_on_application_id"
    t.index ["user_id", "application_id"], name: "index_votes_on_user_id_and_application_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

end
