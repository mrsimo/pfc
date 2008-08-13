class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :target_type, :default => 0
      t.integer :target_id, :null => false
      t.integer :document_id, :null => false
      t.integer :permission, :null => false

      t.timestamps
    end
    add_index :permissions, :target_id
    add_index :permissions, :document_id
  end

  def self.down
    drop_table :permissions
  end
end
