class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :number, :null => false 
      t.string :background
      t.integer :document_id, :null => false

      t.timestamps
    end
    add_index :pages, :document_id
  end

  def self.down
    drop_table :pages
  end
end
