class ItemType < ActiveRecord::Base
  # Get an emulated super type representing the ItemType through the
  # ItemType.item_type key.
  # By putting this into the Ruby logic, we don't have to try and store all item properties
  # and behaviour in the database model; we only have to track the item_types.
  def get_model
    case self.item_type
      when "health_potion"
        return ItemType_HealthPotion.new()
      when "dagger"
        return ItemType_Dagger.new()
      when "sword"
        return ItemType_Sword.new()
      when "katana"
        return ItemType_Katana.new()
      when "sapphire"
        return ItemType_Abstract.new()
      when "bed"
        return ItemType_Abstract.new()
      when "town_portal"
        return ItemType_TownPortal.new()
      when "scroll_fireball"
        return ItemType_Scroll_Fireball.new()
      when "scroll_lightning"
        return ItemType_Scroll_Lightning.new()
      else
        raise ArgumentError, "Unknown item type #{self.item_type}"
    end
  end

  def can_use?
    get_model.can_use?
  end

  def can_equip?
    get_model.can_equip?
  end

  def is_weapon?
    get_model.is_weapon?
  end

  def get_damage_string
    get_model.get_damage_string
  end

  def get_damage
    get_model.get_damage
  end

  # When using this item, will it reduce the quantity?
  def is_consumable?
    true
  end

  # Use this item in some way
  def use(context)
    get_model.use(context, self)
  end
end

class ItemType_Abstract
  def can_use?
    false
  end

  def can_equip?
    false
  end

  def is_weapon?
    false
  end
end

class ItemType_HealthPotion < ItemType_Abstract
  def can_use?
    true
  end

  def use(context, item_type)
    healed = [context.current_player.total_health, context.current_player.current_health + 10].min - context.current_player.current_health
    context.current_player.current_health += healed
    context.add_combat_log "Healed #{healed} health with #{item_type.name}"
    context.current_player.save()
  end
end

class ItemType_Weapon < ItemType_Abstract
  def can_equip?
    true
  end

  def is_weapon?
    true
  end
end

class ItemType_Dagger < ItemType_Weapon
  def get_damage
    1 + Random.rand(4)
  end

  def get_damage_string
    "1d4"
  end
end

class ItemType_Sword < ItemType_Weapon
  def get_damage
    1 + Random.rand(8)
  end

  def get_damage_string
    "1d8"
  end
end

class ItemType_Katana < ItemType_Weapon
  def get_damage
    1 + Random.rand(12)
  end

  def get_damage_string
    "1d12"
  end
end

class ItemType_Scroll_Fireball < ItemType_Weapon
  def get_damage
    (1..5).map{ 1 + Random.rand(3) }.sum
  end

  def get_damage_string
    "5d3"
  end
end

class ItemType_Scroll_Lightning < ItemType_Weapon
  def get_damage
    1 + Random.rand(50)
  end

  def get_damage_string
    "1d50"
  end
end

class ItemType_Sword < ItemType_Weapon
  def get_damage
    1 + Random.rand(8)
  end

  def get_damage_string
    "1d8"
  end
end

class ItemType_TownPortal < ItemType_Abstract
  def can_use?
    true
  end

  def use(context, item_type)
    home_space = Space.where(:name => "Home")
    if home_space.length > 0
      # add 'entered' and 'left' chats
      Chat.new(:space => context.current_player.space, :player => context.current_player, :text => "transported out of " + context.current_player.space.name, :is_leaving => true).save()
      Chat.new(:space => home_space.first, :player => context.current_player, :text => "transported to " + home_space.first.name, :is_entering => true).save()

      context.current_player.space_id = home_space.first.id
      context.add_combat_log "Used #{item_type.name}"
      context.current_player.save()
    end
  end
end
