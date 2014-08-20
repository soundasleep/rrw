class Npc < Character
  after_initialize :init

  # Initialise model defaults
  def init
    self.level ||= 1
    self.current_health ||= 0
    self.total_health ||= 0
  end

  def attacking
    if self.attacking_id
      Player.where(:id => self.attacking_id).first
    end
  end

  def selling
    if self.can_sell
      # TODO respawn logic for NPCs selling
      NpcSells.where(:npc => self).select { |i| i.current_quantity > 0 }
    end
  end

end
