# Abstract class for all characters (Players and NPCs)
class Character < ActiveRecord::Base
  self.abstract_class = true

  def space
    if self.space_id
      Space.where(:id => self.space_id).first
    end
  end

  # Get the amount of damage that this character can deal, as a string.
  def get_damage
    1 + Random.rand(3)
  end

  # Get the amount of damage that this character can deal, as a string.
  def get_damage_string
    return "1d3"
  end
end
