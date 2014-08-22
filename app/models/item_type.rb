class ItemType < ActiveRecord::Base
  # Get an emulated super type representing the ItemType through the
  # ItemType.item_type key.
  # By putting this into the Ruby logic, we don't have to try and store all item properties
  # and behaviour in the database model; we only have to track the item_types.
  def get_model
    case self.item_type
      when "potion_health"
        return ItemType_HealthPotion.new()
      when "dagger"
        return ItemType_Dagger.new()
      when "sword"
        return ItemType_Sword.new()
      when "sapphire"
        return ItemType_Sapphire.new()
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

class ItemType_Sapphire < ItemType_Abstract
end
