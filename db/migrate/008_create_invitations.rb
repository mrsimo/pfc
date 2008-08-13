class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :invitator_id
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end
    add_index :invitations, :user_id
    add_index :invitations, :invitator_id
    add_index :invitations, :group_id
  end

  def self.down
    drop_table :invitations
  end
end
