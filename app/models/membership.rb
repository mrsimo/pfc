# == Schema Information
# Schema version: 14
#
# Table name: memberships
#
#  id         :integer(11)     not null, primary key
#  group_id   :integer(11)     not null
#  user_id    :integer(11)     not null
#  admin      :boolean(1)      
#  created_at :datetime        
#  updated_at :datetime        
#

class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
end
