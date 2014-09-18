class CreateBlockers < ActiveRecord::Migration
  def change
    create_table :blockers do |t|
      t.references :connection, index: true
      t.references :npc, index: true

      t.timestamps
    end
  end
end
