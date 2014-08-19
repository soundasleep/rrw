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

ActiveRecord::Schema.define(version: 20140819011728) do

  create_table "connections", force: true do |t|
    t.string   "name"
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["from_id"], name: "index_connections_on_from_id"
  add_index "connections", ["to_id"], name: "index_connections_on_to_id"

  create_table "players", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "level"
    t.integer  "total_health"
    t.integer  "current_health"
    t.integer  "total_mana"
    t.integer  "current_mana"
    t.integer  "strength"
    t.integer  "intelligence"
    t.integer  "wisdom"
    t.integer  "dexterity"
    t.integer  "charisma"
    t.integer  "luck"
    t.integer  "gold"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "spaces", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
