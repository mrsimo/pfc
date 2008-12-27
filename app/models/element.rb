# == Schema Information
# Schema version: 20081122123130
#
# Table name: elements
#
#  id         :integer(11)     not null, primary key
#  attr       :text            not null
#  page_id    :integer(11)     not null
#  created_at :datetime        
#  updated_at :datetime        
#

class Element < ActiveRecord::Base
  belongs_to :page
end
