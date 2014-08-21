class AddMultiplierToNpcSells < ActiveRecord::Migration
  def change
    add_column :npc_sells, :multiplier, :float
  end
end
