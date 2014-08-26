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
  :forest => Space.create(:name => "Dark forest", :description => "A dark and scary forest, filled with critters"),
  :dusty_cave => Space.create(:name => "Dusty cave", :description => "A dark and dusty cave in the cliffside, delving deep underground"),
  :mountain_pass => Space.create(:name => "Mountain pass", :description => "A cold and dusty mountain pass, with only brief glimpses of the forest below"),
  :mountain_peak => Space.create(:name => "Mountain peak", :description => "A cold and icy mountain peak, unforgiving in its unforgivingness"),
}

# create a bidirectional connection
def connect(spaces, from, to, to_label, from_label)
  # TODO fix the model so we can use :from => rather than :from_id =>
  return {
    :to => Connection.create(:name => to_label, :from_id => spaces[from].id, :to_id => spaces[to].id),
    :from => Connection.create(:name => from_label, :from_id => spaces[to].id, :to_id => spaces[from].id),
  }
end

connections = {
  :home_inn => connect(spaces, :home, :inn, "to the inn", "back home"),
  :home_forest => connect(spaces, :home, :forest, "into the forest", "back home"),
  :forest_dusty_cave => connect(spaces, :forest, :dusty_cave, "into the cave", "out into the forest"),
  :forest_mountain_pass => connect(spaces, :forest, :mountain_pass, "through the mountain pass", "back into the forest"),
  :mountain_pass_mountain_peak => connect(spaces, :mountain_pass, :mountain_peak, "up into the mountains", "down into the forest"),
}

npcs = {
  # TODO fix the model so we can use :space => rather than :space_id =>
  :inn => {
    :innkeeper => Npc.create(:name => "Innkeeper", :friendly => true, :current_health => 50, :total_health => 50, :level => 20, :respawns => 60, :space_id => spaces[:inn].id, :character_type => "innkeeper", :can_sell => true, :can_buy => true),
    :innkeeper_mouse1 => Npc.create(:name => "Mouse 1", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse2 => Npc.create(:name => "Mouse 2", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse3 => Npc.create(:name => "Mouse 3", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse4 => Npc.create(:name => "Mouse 4", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
  },

  :forest => {
    :spider1 => Npc.create(:name => "Black spider 1", :friendly => false, :current_health => 10, :total_health => 10, :level => 2, :respawns => 30, :space_id => spaces[:forest].id, :character_type => "spider"),
    :spider2 => Npc.create(:name => "Black spider 2", :friendly => false, :current_health => 10, :total_health => 10, :level => 2, :respawns => 30, :space_id => spaces[:forest].id, :character_type => "spider"),
  },

  :dusty_cave => {
    :lizard => Npc.create(:name => "Red lizard", :friendly => false, :current_health => 25, :total_health => 25, :level => 3, :respawns => 45, :space_id => spaces[:dusty_cave].id, :character_type => "lizard"),
  },

  :mountain_pass => {
    :black_lizard => Npc.create(:name => "Black lizard", :friendly => false, :current_health => 25, :total_health => 25, :level => 3, :respawns => 120, :space_id => spaces[:mountain_pass].id, :character_type => "lizard"),
  },

  :mountain_peak => {
    :ice_dragon => Npc.create(:name => "Ice dragon", :friendly => false, :current_health => 60, :total_health => 60, :level => 5, :respawns => 120, :space_id => spaces[:mountain_peak].id, :character_type => "ice_dragon"),
  },
}

# set up blocking connections
connections[:mountain_pass_mountain_peak][:to].requires_death_id = npcs[:mountain_pass][:black_lizard].id
connections[:mountain_pass_mountain_peak][:to].save()

items = {
  :health_potion => ItemType.create(:name => "Health potion", :item_type => "potion_health", :description => "A potion that restores 10 health", :base_cost => 10),
  :dagger => ItemType.create(:name => "Dagger", :item_type => "dagger", :description => "A blunt weapon for stabbing things", :base_cost => 20),
  :sword => ItemType.create(:name => "Sword", :item_type => "sword", :description => "A sharp weapon for slicing things", :base_cost => 60),
  :sapphire => ItemType.create(:name => "Sapphire", :item_type => "sapphire", :description => "A shiny sapphire gem that's probably worth a lot", :base_cost => 200),
  :bed => ItemType.create(:name => "Bed", :item_type => "bed", :description => "A safe space to sleep in for the night", :base_cost => 5)
}

NpcSells.create(:npc => npcs[:inn][:innkeeper], :item_type => items[:health_potion], :current_quantity => 5, :max_quantity => 5, :respawns => 60, :multiplier => 1.34)
NpcSells.create(:npc => npcs[:inn][:innkeeper], :item_type => items[:bed], :current_quantity => 5, :max_quantity => 5, :respawns => 60, :multiplier => 1.2)

items.each do |key, value|
  NpcBuys.create(:npc => npcs[:inn][:innkeeper], :item_type => value, :multiplier => 0.67)
end
