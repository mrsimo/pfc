# == Schema Information
# Schema version: 14
#
# Table name: thumbnails
#
#  id           :integer(11)     not null, primary key
#  parent_id    :integer(11)     
#  content_type :string(255)     
#  filename     :string(255)     
#  thumbnail    :string(255)     
#  size         :integer(11)     
#  width        :integer(11)     
#  height       :integer(11)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Thumbnail < ActiveRecord::Base
  has_attachment  :content_type => :image,
                  :processor => 'MiniMagick',
                  :storage => :file_system,
                  :path_prefix => "/document_thumbnails/"
end
