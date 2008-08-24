class AddMoreDefaultsToDocument < ActiveRecord::Migration
  def self.up
    remove_column "documents", "public"
    add_column "documents", "public", :boolean, :default => false
  end

  def self.down
    remove_column "documents", "public"
    add_column "documents", "public", :boolean
  end
end
