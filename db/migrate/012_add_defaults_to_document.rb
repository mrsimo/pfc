class AddDefaultsToDocument < ActiveRecord::Migration
  def self.up
    remove_column "documents", "height"
    add_column "documents", "height", :integer, :default => 600
    remove_column "documents", "width"
    add_column "documents", "width", :integer, :default => 800
    remove_column "documents", "num_pages"
    add_column "documents", "num_pages", :integer, :default => 20
  end

  def self.down
    remove_column "documents", "height"
    add_column "documents", "height", :integer
    remove_column "documents", "width"
    add_column "documents", "width", :integer
    remove_column "documents", "num_pages"
    add_column "documents", "num_pages", :integer
  end
end
