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

ActiveRecord::Schema.define(version: 20131029131344) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "tumblr_posts", force: true do |t|
    t.integer  "tumblr_id",       limit: 8,                 null: false
    t.integer  "note_count",                    default: 0, null: false
    t.string   "blog_name",                                 null: false
    t.string   "post_url",        limit: 1000,              null: false
    t.string   "slug",                                      null: false
    t.string   "tumblr_type",                               null: false
    t.string   "state",                                     null: false
    t.string   "format",                                    null: false
    t.string   "reblog_key",                                null: false
    t.string   "tags",                                      null: false
    t.string   "short_url",                                 null: false
    t.string   "title",           limit: 10000
    t.string   "body",            limit: 10000
    t.string   "caption",         limit: 10000
    t.string   "photos",          limit: 10000
    t.string   "api_repr",        limit: 10000,             null: false
    t.datetime "published_at",                              null: false
    t.datetime "last_scraped_at",                           null: false
  end

  add_index "tumblr_posts", ["tumblr_id"], name: "index_tumblr_posts_on_tumblr_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",   null: false
  end

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
