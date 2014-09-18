class Blocker < ActiveRecord::Base
  belongs_to :connection
  belongs_to :npc
end
