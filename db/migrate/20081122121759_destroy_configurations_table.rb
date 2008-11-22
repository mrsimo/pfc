class DestroyConfigurationsTable < ActiveRecord::Migration
  def self.up
    drop_table :configurations
  end

  def self.down
    
  end
end
