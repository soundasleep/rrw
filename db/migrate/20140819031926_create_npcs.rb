class CreateNpcs < ActiveRecord::Migration
  def change
    create_table :npcs do |t|
      t.string :name
      t.boolean :friendly
      t.integer :current_health
      t.integer :total_health
      t.integer :level

      t.timestamps
    end
  end
end
