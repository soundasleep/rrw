# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'yaml'
file = YAML.load_file('db/world.yml')

cache = {
  :spaces => {},
  :npcs => {},
  :items => {},
}

puts "Loading items..."
file["items"].each do |item_id, item|
  cache[:items][item_id] = ItemType.create({
    :name => item['name'],
    :item_type => item_id,
    :description => item['description'],
    :base_cost => item['cost'],
  })
end

file["spaces"].each do |space_id, space|
  puts "Loading #{space_id}..."

  cache[:spaces][space_id] = Space.create({
    :name => space['name'],
    :description => space['description'],
  })
  cache[:npcs][space_id] = {}

  # npcs
  (space['npcs'] or {}).each do |npc_id, npc|
    cache[:npcs][space_id][npc_id] = Npc.create({
      :name => npc['name'],
      :friendly => npc['friendly'],
      :current_health => npc['health'],
      :total_health => npc['health'],
      :level => npc['level'],
      :respawns => npc['respawns'],
      :space_id => cache[:spaces][space_id].id,
      :character_type => npc_id.split("_").first,
      :can_sell => npc['buys'] != nil,
      :can_buy => npc['sells'] != nil,
    })

    # can_buy
    if npc['buys']
      multiplier = npc['buys']['multiplier'].to_f or 1.0
      npc['buys'].select { |key, value| key != "multiplier" }.each do |key, value|
        value = {} if value === [nil]   # convert array of nil into empty hash
        NpcBuys.create({
          :npc => cache[:npcs][space_id][npc_id],
          :item_type => cache[:items][key],
          :multiplier => (value['multiplier'].to_f or multiplier),
      })
      end
    end

    # can_sell
    if npc['sells']
      multiplier = npc['sells']['multiplier'].to_f or 1
      npc['sells'].select { |key, value| key != "multiplier" }.each do |key, value|
        value = {} if value === [nil]   # convert array of nil into empty hash
        NpcSells.create({
          :npc => cache[:npcs][space_id][npc_id],
          :item_type => cache[:items][key],
          :current_quantity => value['quantity'],
          :max_quantity => value['quantity'],
          :respawns => value['respawns'],
          :multiplier => (value['multiplier'].to_f or multiplier),
      })
      end
    end
  end
end

file["spaces"].each do |space_id, space|
  puts "Loading #{space_id} connections..."

  # connections
  (space['connect'] or {}).each do |connect_id, connect|
    to = Connection.create(:name => connect, :from_id => cache[:spaces][space_id].id, :to_id => cache[:spaces][connect_id].id)

    # blockers
    (space['npcs'] or {}).each do |npc_id, npc|
      if npc['blocks']
        to.requires_death_id = cache[:npcs][space_id][npc_id].id
        to.save()
      end
    end
  end
end
