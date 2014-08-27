# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
spaces = {
  :home => Space.create(:name => "Home", :description => "Your home village"),
  :inn => Space.create(:name => "Inn", :description => "The village inn"),
  :wizard => Space.create(:name => "Wizard den", :description => "A rustic house filled with charms and potions"),
  :forest => Space.create(:name => "Dark forest", :description => "A dark and scary forest, filled with critters"),
  :dusty_cave => Space.create(:name => "Dusty cave", :description => "A dark and dusty cave in the cliffside, delving deep underground"),
  :dusty_cave_2 => Space.create(:name => "Dusty cave Level 2", :description => "The dark caves delves deep underground with only a cool breeze to keep you company"),
  :dusty_cave_3 => Space.create(:name => "Dusty cave Level 3", :description => "A pitch black, desolate chasm deep underground"),
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
  :home_inn => connect(spaces, :home, :inn, "to the inn", "back into town"),
  :home_wizrd => connect(spaces, :home, :wizard, "to the wizard den", "back into town"),
  :home_forest => connect(spaces, :home, :forest, "into the forest", "back into town"),
  :forest_dusty_cave => connect(spaces, :forest, :dusty_cave, "into the cave", "out into the forest"),
  :forest_mountain_pass => connect(spaces, :forest, :mountain_pass, "through the mountain pass", "back into the forest"),
  :dusty_cave_2 => connect(spaces, :dusty_cave, :dusty_cave_2, "deeper into the cave", "back to the first cave level"),
  :dusty_cave_3 => connect(spaces, :dusty_cave_2, :dusty_cave_3, "deeper into the cave", "back to the second cave level"),
  :mountain_pass_mountain_peak => connect(spaces, :mountain_pass, :mountain_peak, "up into the mountains", "down into the forest"),
}

npcs = {
  # TODO fix the model so we can use :space => rather than :space_id =>
  :inn => {
    :innkeeper => Npc.create(:name => "Innkeeper", :friendly => true, :current_health => 100, :total_health => 100, :level => 20, :respawns => 60, :space_id => spaces[:inn].id, :character_type => "innkeeper", :can_sell => true, :can_buy => true),
    :innkeeper_mouse1 => Npc.create(:name => "Mouse 1", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse2 => Npc.create(:name => "Mouse 2", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse3 => Npc.create(:name => "Mouse 3", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
    :innkeeper_mouse4 => Npc.create(:name => "Mouse 4", :friendly => false, :current_health => 3, :total_health => 3, :level => 1, :respawns => 5, :space_id => spaces[:inn].id, :character_type => "mouse"),
  },

  :wizard => {
    :wizard => Npc.create(:name => "Wizard", :friendly => true, :current_health => 100, :total_health => 100, :level => 20, :respawns => 60, :space_id => spaces[:wizard].id, :character_type => "wizard", :can_sell => true, :can_buy => true),
  },

  :forest => {
    :spider1 => Npc.create(:name => "Black spider 1", :friendly => false, :current_health => 10, :total_health => 10, :level => 2, :respawns => 30, :space_id => spaces[:forest].id, :character_type => "spider"),
    :spider2 => Npc.create(:name => "Black spider 2", :friendly => false, :current_health => 10, :total_health => 10, :level => 2, :respawns => 30, :space_id => spaces[:forest].id, :character_type => "spider"),
  },

  :dusty_cave => {
    :mouse => Npc.create(:name => "Mouse", :friendly => false, :current_health => 7, :total_health => 7, :level => 3, :respawns => 45, :space_id => spaces[:dusty_cave].id, :character_type => "mouse"),
  },

  :dusty_cave_2 => {
    :lizard => Npc.create(:name => "Red lizard", :friendly => false, :current_health => 25, :total_health => 25, :level => 3, :respawns => 45, :space_id => spaces[:dusty_cave_2].id, :character_type => "lizard"),
    :spider1 => Npc.create(:name => "Black spider", :friendly => false, :current_health => 30, :total_health => 30, :level => 4, :respawns => 60, :space_id => spaces[:dusty_cave_2].id, :character_type => "spider"),
  },

  :dusty_cave_3 => {
    :ice_dragon => Npc.create(:name => "Black dragon", :friendly => false, :current_health => 40, :total_health => 40, :level => 5, :respawns => 120, :space_id => spaces[:dusty_cave_3].id, :character_type => "black_dragon"),
  },

  :mountain_pass => {
    :black_lizard => Npc.create(:name => "Black lizard", :friendly => false, :current_health => 25, :total_health => 25, :level => 3, :respawns => 120, :space_id => spaces[:mountain_pass].id, :character_type => "lizard"),
  },

  :mountain_peak => {
    :ice_dragon => Npc.create(:name => "Ice dragon", :friendly => false, :current_health => 60, :total_health => 60, :level => 8, :respawns => 120, :space_id => spaces[:mountain_peak].id, :character_type => "ice_dragon"),
  },
}

# set up blocking connections
connections[:mountain_pass_mountain_peak][:to].requires_death_id = npcs[:mountain_pass][:black_lizard].id
connections[:mountain_pass_mountain_peak][:to].save()

connections[:dusty_cave_2][:to].requires_death_id = npcs[:dusty_cave][:mouse].id
connections[:dusty_cave_2][:to].save()

connections[:dusty_cave_3][:to].requires_death_id = npcs[:dusty_cave_2][:spider1].id
connections[:dusty_cave_3][:to].save()

items = {
  :health_potion => ItemType.create(:name => "Health potion", :item_type => "potion_health", :description => "A potion that restores 10 health", :base_cost => 10),
  :dagger => ItemType.create(:name => "Dagger", :item_type => "dagger", :description => "A blunt weapon for stabbing things", :base_cost => 20),
  :sword => ItemType.create(:name => "Sword", :item_type => "sword", :description => "A sharp weapon for slicing things", :base_cost => 60),
  :sapphire => ItemType.create(:name => "Sapphire", :item_type => "sapphire", :description => "A shiny sapphire gem that's probably worth a lot", :base_cost => 200),
  :bed => ItemType.create(:name => "Bed", :item_type => "bed", :description => "A safe space to sleep in for the night", :base_cost => 5),
  :town_portal => ItemType.create(:name => "Scroll of Town Portal", :item_type => "town_portal", :description => "An ancient coded scroll to return you back home", :base_cost => 30),
}

NpcSells.create(:npc => npcs[:inn][:innkeeper], :item_type => items[:health_potion], :current_quantity => 1, :max_quantity => 1, :respawns => 60, :multiplier => 1.34)
NpcSells.create(:npc => npcs[:inn][:innkeeper], :item_type => items[:bed], :current_quantity => 5, :max_quantity => 5, :respawns => 60, :multiplier => 1)

NpcSells.create(:npc => npcs[:wizard][:wizard], :item_type => items[:health_potion], :current_quantity => 3, :max_quantity => 3, :respawns => 60, :multiplier => 1.25)
NpcSells.create(:npc => npcs[:wizard][:wizard], :item_type => items[:town_portal], :current_quantity => 2, :max_quantity => 2, :respawns => 120, :multiplier => 1.25)

[items[:health_potion], items[:dagger], items[:sword]].each do |value|
  NpcBuys.create(:npc => npcs[:inn][:innkeeper], :item_type => value, :multiplier => 0.67)
end
[items[:health_potion], items[:sapphire], items[:town_portal]].each do |value|
  NpcBuys.create(:npc => npcs[:wizard][:wizard], :item_type => value, :multiplier => 0.75)
end
