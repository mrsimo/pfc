class AddEditableToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :editable, :boolean, :default => false
  end

  def self.down
    remove_column :documents, :editable
  end
end
