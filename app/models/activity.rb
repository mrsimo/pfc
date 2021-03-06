# == Schema Information
# Schema version: 20081122123130
#
# Table name: activities
#
#  id          :integer(11)     not null, primary key
#  user_id     :integer(11)     
#  document_id :integer(11)     
#  when        :datetime        
#  anonymous   :boolean(1)      
#  ip          :string(255)     
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :document
end
