# == Schema Information
# Schema version: 20081101173132
#
# Table name: group_permissions
#
#  id          :integer(11)     not null, primary key
#  document_id :integer(11)     not null
#  group_id    :integer(11)     not null
#  permission  :integer(11)     default(0)
#  created_at  :datetime        
#  updated_at  :datetime        
#

class GroupPermission < ActiveRecord::Base
  belongs_to :document
  belongs_to :group
end
