class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.references :player, index: true
      t.string :text
      t.references :space, index: true

      t.timestamps
    end
  end
end
