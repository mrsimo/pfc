class RemoveAttachmentFromPages < ActiveRecord::Migration
  def self.up
    remove_column "pages", "parent_id"
    remove_column "pages", "content_type"
    remove_column "pages", "filename"
    remove_column "pages", "thumbnail"
    remove_column "pages", "size"
    remove_column "pages", "width"
    remove_column "pages", "height"
  end

  def self.down
    add_column "pages", "parent_id", :integer
    add_column "pages", "content_type", :string
    add_column "pages", "filename", :string
    add_column "pages", "thumbnail", :string
    add_column "pages", "size", :integer
    add_column "pages", "width", :integer
    add_column "pages", "height", :integer
  end
end
