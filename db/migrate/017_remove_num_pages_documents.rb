class RemoveNumPagesDocuments < ActiveRecord::Migration
  def self.up
    remove_column "documents", "num_pages"
  end

  def self.down
    add_column "documents", "num_pages", :integer
  end
end
