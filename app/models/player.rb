class Player < ActiveRecord::Base
  after_initialize :init
  has_one :space

  # Initialise model defaults
  def init
    self.name ||= "Unnamed"
    self.level ||= 1
    self.current_health ||= 0
    self.total_health ||= 0
    self.current_mana ||= 0
    self.total_mana ||= 0
  end

  def space
    if self.space_id
      Space.where(:id => self.space_id).first
    end
  end
end
