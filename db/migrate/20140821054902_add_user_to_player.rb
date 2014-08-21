class AddUserToPlayer < ActiveRecord::Migration
  def change
    add_reference :players, :user, index: true
    add_column :players, :is_active, :boolean
  end
end
