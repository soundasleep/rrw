class AddAttackingToNpc < ActiveRecord::Migration
  def change
    add_reference :npcs, :attacking, index: true
  end
end
