class AddXpToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :xp, :integer
  end
end
