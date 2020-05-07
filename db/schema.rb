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

ActiveRecord::Schema.define(version: 20170110040726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

# Could not dump table "applications" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "application_id", null: false
    t.string   "body",           null: false
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

# Could not dump table "profiles" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "sponsorships", force: :cascade do |t|
    t.integer  "application_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "users" because of following FrozenError
#   can't modify frozen String: "false"

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
