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
  end
end
