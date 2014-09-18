# Abstract class for all characters (Players and NPCs)
class Character < ActiveRecord::Base
  include Loggable

  self.abstract_class = true

  def space
    if self.space_id
      Space.where(:id => self.space_id).first
    end
  end

  # Can this character type receive loot?
  def can_loot?
    false
  end

  # Can this character receive XP?
  def can_xp?
    false
  end

  # Do we keep track of what NPC killed this character?
  def track_killed_by?
    false
  end

  def track_score?
    false
  end

  # Get the amount of damage that this character can deal, as a string.
  def get_damage
    1 + Random.rand(3)
  end

  # Get the amount of damage that this character can deal, as a string.
  def get_damage_string
    "1d3"
  end

  # Get the loot from this character if it had just died, returns e.g. {:gold => 1}
  # @return a hash
  def get_loot
    {
      :gold => Random.rand(level * 5),
      :items => get_drops
    }
  end

  def get_drops
    []
  end

  # Get the amount of XP that killing this character would return
  # @return a number
  def get_xp
    return 3 * level
  end

  def do_attack(loggable, npc)
    p1 = self
    p2 = npc

    damage = p1.get_damage
    damage_string = p1.get_damage_string
    p2.current_health -= damage
    p2.save()
    loggable.add_log "#{p1.name} attacked #{p2.name} with #{damage_string} causing #{damage} damage"
    if p2.current_health <= 0
      p2.died_at = Time.now
      p2.save()
      loggable.add_log "#{p2.name} has died"

      # track who killed this player
      if p2.track_killed_by?
        p2.killed_by_id = p1.id
        p2.save()

        Chat.new(:space => p2.space, :player => p2, :text => "died", :is_death => true).save()

        # stop the NPC attacking the player
        # TODO have a parent class for (players, NPCs) rather than this fragile logic
        p1.attacking_id = nil
        p1.save()
      end

      # do post-combat mechanics: XP, loot
      if p1.can_xp?
        xp = p2.get_xp
        loggable.add_log "#{p1.name} gained #{xp} XP"
        if p1.xp == nil
          p1.xp = 0
        end
        p1.xp += xp
        p1.save()

        # upgrade levels?
        if p1.xp >= p1.next_level_xp
          p1.level += 1
          loggable.add_log "#{p1.name} has achieved level #{p1.level}!"
          p1.current_health += 2
          p1.total_health += 2
          loggable.add_log "#{p1.name} now has #{p1.current_health}/#{p1.total_health} health"
          p1.save()
        else
          # loggable.add_log "#{p1.name} has #{p1.xp} XP, needs #{p1.next_level_xp} for the next level"
        end

        # remove one-use weapons?
        if p1.current_weapon and p1.current_weapon.item_type.is_one_attack?
          loggable.add_log "#{p1.current_weapon.item_type.name} has been used"
          remove_item(p1, p1.current_weapon.item_type)

          if not p1.current_weapon
            # equip the next weapon, if there are any
            if weapon = p1.player_items.where(:equipped => false).select { |item| item.item_type.is_weapon? }.first
              equip_item(weapon)
            end
          end
        end
      end

      if p1.can_loot?
        loot = p2.get_loot
        loggable.add_log "#{p1.name} receives #{loot[:gold]} gold"
        # TODO other loot types
        # maybe create a new Loot class?
        p1.gold += loot[:gold]
        p1.save()

        # any other items?
        loot[:items].each do |item_type|
          loggable.add_log "#{p1.name} also receives one #{item_type.name}"
          add_item p1, item_type
        end
      end

      # tracks score?
      if p1.track_score?
        p1.update_score()
      end
    end
  end

end
