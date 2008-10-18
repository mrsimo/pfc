class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.references :user
      t.references :document
      t.column :when, :datetime
      t.column :anonymous, :boolean, :default => false
      t.column :ip, :string
      
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
