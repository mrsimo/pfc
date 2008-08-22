class RemoveBackgroundToPage < ActiveRecord::Migration
  def self.up
    remove_column "pages", "background"
  end

  def self.down
    add_column "pages", "background", :string
  end
end
