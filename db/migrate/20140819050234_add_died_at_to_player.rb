class AddDiedAtToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :died_at, :datetime
  end
end
