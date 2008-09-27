# == Schema Information
# Schema version: 19
#
# Table name: documents
#
#  id           :integer(11)     not null, primary key
#  title        :string(255)     
#  description  :text            
#  current_page :integer(11)     default(1)
#  user_id      :integer(11)     not null
#  created_at   :datetime        
#  updated_at   :datetime        
#  height       :integer(11)     default(600)
#  width        :integer(11)     default(800)
#  has_file     :boolean(1)      
#  public       :boolean(1)      
#

class Document < ActiveRecord::Base
  has_many :pages, :dependent => :destroy
  has_many :elements, :through => :pages
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  
  has_many :document_permissions, :dependent => :destroy
  has_many :users_with_access, :through => :document_permissions, :class_name => "User", :source => "user"
  
  has_many :group_permissions, :dependent => :destroy
  has_many :groups_with_access, :through => :group_permissions, :class_name => "Group", :source => "group"
  
  acts_as_ferret :fields => [ :title, :description ]
  
  # Validations
  validates_presence_of :title, :description
  
  def get_current_page
    p = Page.find_by_number_and_document_id self.current_page, self.id
    if !p
      p = self.pages.find(:first)
      self.current_page = p.number
      self.save
    end
    p
  end
  def needed_area
    width  = 99999999
    height = 99999999
    self.pages.each do |p|
      width  = width  < p.image.width ? width : p.image.width
      height = height < p.image.height ? height : p.image.height
    end
    {:width => width,:height => height}
  end
  
  def is_user_admin?(user)
    dp = DocumentPermission.find_by_user_id_and_document_id user, self
    dp.permission != 0 unless dp.nil?
  end
  
  def is_group_admin?(group)
    gp = GroupPermission.find_by_group_id_and_document_id group,self
    gp.permission != 0
  end
  
  def toggle_user_perms(user)
    dp = DocumentPermission.find_by_user_id_and_document_id user, self
    dp.permission = (dp.permission == 0 ? 1 : 0)
    dp.save
  end
  
  def toggle_group_perms(group)
    gp = GroupPermission.find_by_group_id_and_document_id group, self
    gp.permission = (gp.permission == 0 ? 1 : 0)
    gp.save
  end
  
  def can_be_seen_by(user)
    can_he = false
    can_he = true if self.owner == user
    can_he = true if (self.groups_with_access & user.groups).size > 0
    can_he = true if user.accessible_documents.include? self
    can_he
  end
  
  def can_be_edited_by(user)
    can_he = false
    # To be able to edit he must either be the owner, have a group permission, or have direct permission
    can_he = true if self.owner == user #owner

    # group permission
    groups =  (self.groups_with_access & user.groups)
    for group in groups
      can_he = true if self.is_group_admin? group
    end
    
    # user permission
    can_he = true if self.is_user_admin? user
    can_he
  end
  
  def can_be_deleted_by(user)
    self.owner == user
  end
  
  def stats
   "#{self.pages.size} pages, #{self.elements.size} drawings, #{self.users_with_access.size} users, #{self.groups_with_access.size} groups" 
  end
end