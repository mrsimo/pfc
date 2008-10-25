class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.column :file, :string
      t.column :dir, :string
      t.column :done, :boolean, :default => false
      t.references :document
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
