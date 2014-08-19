class AddSpaceIdToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :space_id, :integer
  end
end
