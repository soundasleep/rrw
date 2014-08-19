class AddKilledByToPlayer < ActiveRecord::Migration
  def change
    add_reference :players, :killed_by, index: true
  end
end
