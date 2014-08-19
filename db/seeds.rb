# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
spaces = {
  :home => Space.create(:name => "Home", :description => "The home location"),
  :inn => Space.create(:name => "Inn", :description => "The village inn"),
  :forest => Space.create(:name => "Dark forest", :description => "A dark and scary forest, filled with critters")
}

Connection.create(:name => "to the inn", :from_id => spaces[:home].id, :to_id => spaces[:inn].id)
Connection.create(:name => "back home", :from_id => spaces[:inn].id, :to_id => spaces[:home].id)
Connection.create(:name => "into the forest", :from_id => spaces[:home].id, :to_id => spaces[:forest].id)
Connection.create(:name => "back home", :from_id => spaces[:forest].id, :to_id => spaces[:home].id)

npcs = {
  :inn => {
    :innkeeper => Npc.create(:name => "Innkeeper", :friendly => true, :current_health => 50, :total_health => 50, :level => 20, :respawns => 60, :space_id => spaces[:inn].id, :character_type => "innkeeper"),
    :innkeeper_mouse1 => Npc.create(:name => "Mouse 1", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse2 => Npc.create(:name => "Mouse 2", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse3 => Npc.create(:name => "Mouse 3", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse4 => Npc.create(:name => "Mouse 4", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
  },

  :forest => {
    :spider1 => Npc.create(:name => "Black spider 1", :friendly => false, :current_health => 10, :total_health => 10, :level => 2, :respawns => 30, :space_id => spaces[:forest].id, :character_type => "spider"),
    :spider2 => Npc.create(:name => "Black spider 2", :friendly => false, :current_health => 10, :total_health => 10, :level => 2, :respawns => 30, :space_id => spaces[:forest].id, :character_type => "spider"),
  },
}
