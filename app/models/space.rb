class Space < ActiveRecord::Base
  def connections
    Connection.where(:from_id => self.id)
  end
end
