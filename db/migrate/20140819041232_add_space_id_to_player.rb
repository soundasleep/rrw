class AddSpaceIdToPlayer < ActiveRecord::Migration
  def change
    add_reference :players, :space, index: true
  end
end
