class AddRequiresDeathToConnection < ActiveRecord::Migration
  def change
    add_reference :connections, :requires_death, index: true
  end
end
