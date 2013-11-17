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

ActiveRecord::Schema.define(version: 20131116231543) do

  create_table "profiles", force: true do |t|
    t.integer  "user_id",                 null: false
    t.string   "twitter"
    t.string   "facebook"
    t.string   "website"
    t.string   "linkedin"
    t.string   "blog"
    t.string   "bio",        limit: 2000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

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
    t.string   "state",      null: false
  end

end
