class CreateGroupPermissions < ActiveRecord::Migration
  def self.up
    create_table :group_permissions do |t|
      t.integer :document_id, :null => false
      t.integer :group_id, :null => false
      t.integer :permission, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :group_permissions
  end
end
