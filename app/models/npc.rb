class Npc < Character
  after_initialize :init

  # Initialise model defaults
  def init
    self.level ||= 1
    self.total_health ||= 5
    self.current_health ||= self.total_health
    self.character_type ||= "default"

    # Check that character_type is valid, or throw an ArgumentError
    raise ArgumentError, "Unknown character type #{character_type}" unless model_classes.has_key?(character_type)
  end

  # Get an emulated super type representing the ItemType through the
  # ItemType.item_type key.
  # By putting this into the Ruby logic, we don't have to try and store all item properties
  # and behaviour in the database model; we only have to track the item_types.
  def get_model
    return model_classes[character_type].new()
  end

  def model_classes
    {
      "default" => Npc_Default,
      "innkeeper" => Npc_Innkeeper,
      "wizard" => Npc_Wizard,
      "mouse" => Npc_Mouse,
      "spider" => Npc_Spider,
      "lizard" => Npc_Lizard,
      "ice_dragon" => Npc_IceDragon,
      "black_dragon" => Npc_BlackDragon,
    }
  end

  belongs_to :attacking, class_name: "Player"

  def attacking
    if self.attacking_id
      Player.where(:id => self.attacking_id).first
    end
  end

  # what can this NPC currently sell?
  # Returns NpcSells
  def selling
    if self.can_sell
      NpcSells.where(:npc => self).select { |i| i.current_quantity > 0 }
    end
  end

  # what can this NPC currently buy from this inventory?
  # Returns NpcBuys
  def buying(player)
    if self.can_buy
      NpcBuys.where(:npc => self).select do |buy|
        PlayerItem.where(:player_id => player.id, :item_type_id => buy.item_type_id).length > 0
      end
    end
  end

  def space
    Space.where(:id => space_id).first
  end

  def get_damage
    get_model.get_damage
  end

  def get_damage_string
    get_model.get_damage_string
  end

  # Return an array of drops (ItemTypes) that this character will have dropped on death.
  # Can be random etc
  def get_drops
    get_model.get_drops
  end

end

class Npc_Abstract
  def get_drops
    []
  end

  # Roll a 1d100 and return true if the result is less than the given argument.
  def chance(f)
    return Random.rand(f * 100) < f
  end
end

class Npc_Default < Npc_Abstract
end

class Npc_Innkeeper < Npc_Abstract
  def get_damage
    1 + Random.rand(30)
  end
  def get_damage_string
    "1d30"
  end
end

class Npc_Wizard < Npc_Abstract
  def get_damage
    1 + Random.rand(30)
  end
  def get_damage_string
    "1d30"
  end
end

class Npc_Mouse < Npc_Abstract
  def get_damage
    1 + Random.rand(3)
  end
  def get_damage_string
    "1d3"
  end

  def get_drops
    drops = []
    if chance(20)
      drops.push ItemType.where(:item_type => "dagger").first()
    end
    return drops
  end
end

class Npc_Spider < Npc_Abstract
  def get_damage
    1 + Random.rand(4)
  end
  def get_damage_string
    "1d4"
  end

  def get_drops
    drops = []
    if chance(50)
      drops.push ItemType.where(:item_type => "dagger").first()
    end
    return drops
  end
end

class Npc_Lizard < Npc_Abstract
  def get_damage
    1 + Random.rand(5)
  end

  def get_damage_string
    "1d5"
  end

  def get_drops
    drops = []
    if chance(80)
      drops.push ItemType.where(:item_type => "sword").first()
    end
    if chance(10)
      drops.push ItemType.where(:item_type => "town_portal").first()
    end
    return drops
  end
end

class Npc_BlackDragon < Npc_Abstract
  def get_damage
    1 + Random.rand(8)
  end
  def get_damage_string
    "1d10"
  end

  def get_drops
    drops = []
    if chance(35)
      drops.push ItemType.where(:item_type => "sapphire").first()
    end
    if chance(30)
      drops.push ItemType.where(:item_type => "town_portal").first()
    end
    if chance(10)
      drops.push ItemType.where(:item_type => "katana").first()
    end
    return drops
  end
end

class Npc_IceDragon < Npc_Abstract
  def get_damage
    (1 + Random.rand(6)) + (1 + Random.rand(6))
  end
  def get_damage_string
    "2d6"
  end

  def get_drops
    drops = []
    if chance(95)
      drops.push ItemType.where(:item_type => "sapphire").first()
    end
    if chance(20)
      drops.push ItemType.where(:item_type => "town_portal").first()
    end
    if chance(20)
      drops.push ItemType.where(:item_type => "katana").first()
    end
    return drops
  end
end
