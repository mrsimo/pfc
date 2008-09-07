class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.column :images_path, :string
      t.column :thumbnails_path, :string
      t.column :teamp_path, :string
    end
  end

  def self.down
    drop_table :configurations
  end
end
