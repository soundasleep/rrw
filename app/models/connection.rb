class Connection < ActiveRecord::Base
  belongs_to :from
  belongs_to :to

  def from
    Space.where(:id => from_id).first
  end
  def to
    Space.where(:id => to_id).first
  end
end
