class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name, :null => false
      t.text :description
      t.integer :owner_id, :null => false

      t.timestamps
    end
    add_index :groups, :owner_id
  end

  def self.down
    drop_table :groups
  end
end
