class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.text :attr, :null => false 
      t.integer :page_id, :null => false

      t.timestamps
    end
    add_index :elements, :page_id
  end

  def self.down
    drop_table :elements
  end
end
