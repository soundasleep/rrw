class Npc < Character
  def attacking
    if self.attacking_id
      Player.where(:id => self.attacking_id).first
    end
  end
end
