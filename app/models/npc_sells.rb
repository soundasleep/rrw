class NpcSells < ActiveRecord::Base
  belongs_to :npc
  belongs_to :item_type
end
