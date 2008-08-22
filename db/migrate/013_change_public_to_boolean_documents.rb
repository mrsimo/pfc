class ChangePublicToBooleanDocuments < ActiveRecord::Migration
  def self.up
    remove_column "documents", "public"
    add_column "documents", "public", :boolean
  end

  def self.down
    remove_column "documents", "public"
    add_column "documents", "public", :integer
  end
end
