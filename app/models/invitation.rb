# == Schema Information
# Schema version: 20081122123130
#
# Table name: invitations
#
#  id         :integer(11)     not null, primary key
#  target_id  :integer(11)     
#  source_id  :integer(11)     
#  group_id   :integer(11)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Invitation < ActiveRecord::Base
  belongs_to :source, :class_name => "User", :foreign_key => "source_id"
  belongs_to :target, :class_name => "User", :foreign_key => "target_id"
  belongs_to :group
end
