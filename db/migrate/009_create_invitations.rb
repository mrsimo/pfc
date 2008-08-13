class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :target_id
      t.integer :source_id
      t.integer :group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
