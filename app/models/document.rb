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
    Page.find_by_number_and_document_id self.current_page, self.id
  end
  def needed_area
    width  = 99999999
    height = 99999999
    self.pages.each do |p|
      width  = width  > p.image.width ? width : p.image.width
      height = height > p.image.height ? height : p.image.height
    end
    {:width => width,:height => height}
  end
end
