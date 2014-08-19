class Player < Character
  after_initialize :init

  # Initialise model defaults
  def init
    self.name ||= "Unnamed"
    self.level ||= 1
    self.current_health ||= 0
    self.total_health ||= 0
    self.current_mana ||= 0
    self.total_mana ||= 0
    self.gold ||= 0
    self.xp ||= 0
  end

  def killed_by
    if self.killed_by_id
      Npc.where(:id => self.killed_by_id).first
    end
  end

  def can_loot?
    true
  end

  def can_xp?
    true
  end

  def track_killed_by?
    true
  end

  def next_level_xp
    (20.0 ** (1 + 0.2 * (level - 1)) - 10).to_i
  end
end
