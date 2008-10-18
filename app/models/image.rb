# == Schema Information
# Schema version: 19
#
# Table name: images
#
#  id           :integer(11)     not null, primary key
#  parent_id    :integer(11)     
#  content_type :string(255)     
#  filename     :string(255)     
#  thumbnail    :string(255)     
#  size         :integer(11)     
#  width        :integer(11)     
#  height       :integer(11)     
#  page_id      :integer(11)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Image < ActiveRecord::Base
  belongs_to :page
  
  has_attachment  :content_type => :image,
                  :processor => 'MiniMagick',
                  :storage => :file_system,
                  :thumbnails => {:small => '85x>',
                                  :medium => '360x360>',
                                  :big => '800x800>'},
                  :thumbnail_class => "Thumbnail",
                  :path_prefix => "/document_images/"
end
