class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :name
      t.references :from, index: true
      t.references :to, index: true

      t.timestamps
    end
  end
end
