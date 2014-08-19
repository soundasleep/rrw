# Abstract class for all characters (Players and NPCs)
class Character < ActiveRecord::Base
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
    }
  end

  # Get the amount of XP that killing this character would return
  # @return a number
  def get_xp
    return 3 * level
  end
end
