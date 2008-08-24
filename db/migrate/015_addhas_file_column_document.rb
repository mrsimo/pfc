class AddhasFileColumnDocument < ActiveRecord::Migration
  def self.up
    add_column "documents", "has_file", :boolean, :default => false
  end

  def self.down
    remove_column "documents", "has_file"
  end
end
