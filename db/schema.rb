# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160206222501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "state",                               null: false
    t.boolean  "agreement_terms",     default: false, null: false
    t.boolean  "agreement_policies",  default: false, null: false
    t.boolean  "agreement_female",    default: false, null: false
    t.datetime "submitted_at"
    t.datetime "processed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "stale_email_sent_at"
  end

  add_index "applications", ["state"], name: "index_applications_on_state", using: :btree
  add_index "applications", ["user_id"], name: "index_applications_on_user_id", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.integer  "application_id",              null: false
    t.string   "body",           limit: 2000, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "configurables", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configurables", ["name"], name: "index_configurables_on_name", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id",                                        null: false
    t.string   "twitter"
    t.string   "facebook"
    t.string   "website"
    t.string   "linkedin"
    t.string   "blog"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_name_on_site",              default: false, null: false
    t.string   "gravatar_email"
    t.string   "summary",           limit: 2000
    t.string   "reasons",           limit: 2000
    t.string   "projects",          limit: 2000
    t.string   "skills",            limit: 2000
    t.string   "feminism",          limit: 2000
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "sponsorships", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "state",                                        null: false
    t.datetime "last_logged_in_at"
    t.string   "email_for_google"
    t.integer  "dues_pledge"
    t.boolean  "is_admin",                     default: false
    t.boolean  "setup_complete"
    t.text     "membership_note"
    t.string   "stripe_customer_id"
    t.datetime "last_stripe_charge_succeeded"
    t.boolean  "is_scholarship",               default: false
    t.boolean  "voting_policy_agreement",      default: false
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "application_id", null: false
    t.boolean  "value",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["application_id"], name: "index_votes_on_application_id", using: :btree
  add_index "votes", ["user_id", "application_id"], name: "index_votes_on_user_id_and_application_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
