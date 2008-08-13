class CreateDocumentPermissions < ActiveRecord::Migration
  def self.up
    create_table :document_permissions do |t|
      t.integer :document_id, :null => false
      t.integer :user_id, :null => false
      t.integer :permission, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :document_permissions
  end
end
