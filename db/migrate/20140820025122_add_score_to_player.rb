class AddScoreToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :score, :integer
    add_index :players, :score
  end
end
