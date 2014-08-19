class Npc < ActiveRecord::Base
  def attacking
    if self.attacking_id
      Player.where(:id => self.attacking_id).first
    end
  end
end
