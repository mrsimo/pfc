# == Schema Information
# Schema version: 14
#
# Table name: elements
#
#  id         :integer(11)     not null, primary key
#  attr       :string(255)     default(""), not null
#  page_id    :integer(11)     not null
#  created_at :datetime        
#  updated_at :datetime        
#

class Element < ActiveRecord::Base
  belongs_to :page
end
