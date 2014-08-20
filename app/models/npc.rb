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

  # what can this NPC currently sell?
  def selling
    if self.can_sell
      NpcSells.where(:npc => self).select { |i| i.current_quantity > 0 }
    end
  end

end
