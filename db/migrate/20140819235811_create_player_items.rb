class CreatePlayerItems < ActiveRecord::Migration
  def change
    create_table :player_items do |t|
      t.references :player, index: true
      t.references :item_type, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
