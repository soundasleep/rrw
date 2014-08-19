class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.text :description
      t.integer :level
      t.integer :total_health
      t.integer :current_health
      t.integer :total_mana
      t.integer :current_mana
      t.integer :strength
      t.integer :intelligence
      t.integer :wisdom
      t.integer :dexterity
      t.integer :charisma
      t.integer :luck
      t.integer :gold

      t.timestamps
    end
  end
end
