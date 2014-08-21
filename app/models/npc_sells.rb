class NpcSells < ActiveRecord::Base
  belongs_to :npc
  belongs_to :item_type

  after_initialize :init

  # Initialise model defaults
  def init
    self.multiplier ||= 1
  end

  def cost
    (self.multiplier * item_type.base_cost).to_i
  end

end
