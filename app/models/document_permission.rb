# == Schema Information
# Schema version: 13
#
# Table name: document_permissions
#
#  id          :integer(11)     not null, primary key
#  document_id :integer(11)     not null
#  user_id     :integer(11)     not null
#  permission  :integer(11)     default(0)
#  created_at  :datetime        
#  updated_at  :datetime        
#

class DocumentPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :document
end
