class Group < ActiveRecord::Base
  has_many :memberships
  has_many :members, :through => :memberships, :source => "user"
  
  belongs_to :owner, :class_name => "User"  
  has_many :group_permissions
  has_many :accessible_documents, :class_name => "Document", :through => :group_permissions
  
  def membership(user)
    Membership.find_by_user_id_and_group_id(user.id,self.id)
  end
end
