class Connection < ActiveRecord::Base
  belongs_to :from, class_name: "Space"
  belongs_to :to, class_name: "Space"

  has_many :blockers

  def is_blocked?
    alive_blockers.length > 0
  end

  def alive_blockers
    blockers.select { |b| b.npc.current_health > 0 }
  end

  def blocked_by
    alive_blockers.first.npc.name
  end
end
