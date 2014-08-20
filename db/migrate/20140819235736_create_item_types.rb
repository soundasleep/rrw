class CreateItemTypes < ActiveRecord::Migration
  def change
    create_table :item_types do |t|
      t.string :name
      t.string :item_type
      t.text :description
      t.integer :base_cost

      t.timestamps
    end
  end
end
