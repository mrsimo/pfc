class Group < ActiveRecord::Base
  has_and_belongs_to_many :members, :class_name => "User"
  belongs_to :owner, :class_name => "User"  
  has_many :group_permissions
  has_many :accessible_documents, :class_name => "Document", :through => :group_permissions
end
