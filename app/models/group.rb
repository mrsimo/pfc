# == Schema Information
# Schema version: 19
#
# Table name: groups
#
#  id          :integer(11)     not null, primary key
#  name        :string(255)     default(""), not null
#  description :text            
#  owner_id    :integer(11)     not null
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Group < ActiveRecord::Base
  has_many :memberships
  has_many :members, :through => :memberships, :source => "user"  
  
  has_many :admin_memberships, :class_name => "Membership", :conditions => {:admin => true}
  has_many :user_memberships,  :class_name => "Membership", :conditions => {:admin => false}
  
  has_many :admins, :through => :admin_memberships, :source => "user"
  has_many :users,  :through => :user_memberships,  :source => "user"
  
  belongs_to :owner, :class_name => "User"  
  
  has_many :group_permissions
  has_many :documents, :through => :group_permissions, :class_name => "Document"
  
  # Validations
  validates_presence_of :name
  
  acts_as_textiled :description
  
  def membership(user)
    Membership.find_by_user_id_and_group_id(user,self)
  end
  
  def is_member?(user)
    self.members.include? user
  end
  
  def is_admin?(user)
    self.admins.include? user
  end
  
  def is_owner?(user)
    self.owner == user
  end
  
  def stats
    "#{self.documents.size} documents available"
  end
  
end
