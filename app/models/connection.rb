class Connection < ActiveRecord::Base
  belongs_to :from, class_name: "Space"
  belongs_to :to, class_name: "Space"

  belongs_to :requires_death, class_name: "Npc"
end
