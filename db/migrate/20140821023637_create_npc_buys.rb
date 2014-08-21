class CreateNpcBuys < ActiveRecord::Migration
  def change
    create_table :npc_buys do |t|
      t.references :npc, index: true
      t.references :item_type, index: true
      t.float :multiplier

      t.timestamps
    end
  end
end
