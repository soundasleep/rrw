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

ActiveRecord::Schema.define(version: 20140821024924) do

  create_table "connections", force: true do |t|
    t.string   "name"
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["from_id"], name: "index_connections_on_from_id"
  add_index "connections", ["to_id"], name: "index_connections_on_to_id"

  create_table "item_types", force: true do |t|
    t.string   "name"
    t.string   "item_type"
    t.text     "description"
    t.integer  "base_cost"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "npc_buys", force: true do |t|
    t.integer  "npc_id"
    t.integer  "item_type_id"
    t.float    "multiplier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "npc_buys", ["item_type_id"], name: "index_npc_buys_on_item_type_id"
  add_index "npc_buys", ["npc_id"], name: "index_npc_buys_on_npc_id"

  create_table "npc_sells", force: true do |t|
    t.integer  "npc_id"
    t.integer  "item_type_id"
    t.integer  "current_quantity"
    t.integer  "max_quantity"
    t.integer  "respawns"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "multiplier"
  end

  add_index "npc_sells", ["item_type_id"], name: "index_npc_sells_on_item_type_id"
  add_index "npc_sells", ["npc_id"], name: "index_npc_sells_on_npc_id"

  create_table "npcs", force: true do |t|
    t.string   "name"
    t.boolean  "friendly"
    t.integer  "current_health"
    t.integer  "total_health"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "space_id"
    t.integer  "attacking_id"
    t.integer  "respawns"
    t.datetime "died_at"
    t.string   "character_type"
    t.boolean  "can_sell"
    t.boolean  "can_buy"
  end

  add_index "npcs", ["attacking_id"], name: "index_npcs_on_attacking_id"
  add_index "npcs", ["can_buy"], name: "index_npcs_on_can_buy"
  add_index "npcs", ["can_sell"], name: "index_npcs_on_can_sell"
  add_index "npcs", ["character_type"], name: "index_npcs_on_character_type"
  add_index "npcs", ["space_id"], name: "index_npcs_on_space_id"

  create_table "player_items", force: true do |t|
    t.integer  "player_id"
    t.integer  "item_type_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "equipped"
  end

  add_index "player_items", ["item_type_id"], name: "index_player_items_on_item_type_id"
  add_index "player_items", ["player_id"], name: "index_player_items_on_player_id"

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
    t.integer  "xp"
    t.integer  "killed_by_id"
    t.datetime "died_at"
    t.integer  "score"
  end

  add_index "players", ["killed_by_id"], name: "index_players_on_killed_by_id"
  add_index "players", ["score"], name: "index_players_on_score"
  add_index "players", ["space_id"], name: "index_players_on_space_id"

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
