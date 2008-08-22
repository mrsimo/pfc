# == Schema Information
# Schema version: 13
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
#  num_pages    :integer(11)     default(20)
#  public       :boolean(1)      
#

class Document < ActiveRecord::Base
  has_many :pages, :dependent => :destroy
  has_many :elements, :through => :pages
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
end
