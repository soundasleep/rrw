# Abstract class for all characters (Players and NPCs)
class Character < ActiveRecord::Base
  self.abstract_class = true

  def space
    if self.space_id
      Space.where(:id => self.space_id).first
    end
  end
end
