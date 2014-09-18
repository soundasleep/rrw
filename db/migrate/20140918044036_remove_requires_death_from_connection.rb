class RemoveRequiresDeathFromConnection < ActiveRecord::Migration
  def change
    remove_reference :connections, :requires_death, index: true
  end
end
