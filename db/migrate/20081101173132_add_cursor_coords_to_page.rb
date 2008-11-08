class AddCursorCoordsToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :cursorx, :integer
    add_column :pages, :cursory, :integer
    add_column :pages, :cursorr, :integer
  end

  def self.down
    remove_column :pages, :cursorx
    remove_column :pages, :cursory
    remove_column :pages, :cursorr
  end
end
