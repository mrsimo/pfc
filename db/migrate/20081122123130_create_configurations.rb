class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :name
      t.string :description
      t.string :permalink
      t.text :value
      t.string :content_type

      t.timestamps
    end
    add_index :configurations, :permalink
  end

  def self.down
    drop_table :configurations
  end
end
