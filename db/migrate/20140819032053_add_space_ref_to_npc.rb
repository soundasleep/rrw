class AddSpaceRefToNpc < ActiveRecord::Migration
  def change
    add_reference :npcs, :space, index: true
  end
end
