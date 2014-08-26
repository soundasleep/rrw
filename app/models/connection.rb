class Connection < ActiveRecord::Base
  belongs_to :from
  belongs_to :to

  def from
    Space.where(:id => from_id).first
  end
  def to
    Space.where(:id => to_id).first
  end

  def requires_death
    Npc.where(:id => self.requires_death_id).first if self.requires_death_id
  end
end
