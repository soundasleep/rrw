class PlayerItem < ActiveRecord::Base
  belongs_to :player
  belongs_to :item_type

  after_initialize :init

  # Initialise model defaults
  def init
    self.quantity ||= 1
    self.equipped ||= false
  end
end
