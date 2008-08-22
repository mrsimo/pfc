# == Schema Information
# Schema version: 14
#
# Table name: pages
#
#  id           :integer(11)     not null, primary key
#  number       :integer(11)     not null
#  document_id  :integer(11)     not null
#  created_at   :datetime        
#  updated_at   :datetime        
#  parent_id    :integer(11)     
#  content_type :string(255)     
#  filename     :string(255)     
#  thumbnail    :string(255)     
#  size         :integer(11)     
#  width        :integer(11)     
#  height       :integer(11)     
#

class Page < ActiveRecord::Base
  has_many :elements, :dependent => :destroy
  belongs_to :document
  
  has_attachment  :content_type => :image,
                  :processor => 'MiniMagick',
                  :storage => :file_system,
                  :thumbnails => {:small => '120x120>',
                                  :medium => '360x360>',
                                  :big => '800x800>'},
                  :thumbnail_class => "Thumbnail",
                  :path_prefix => "/document_images/"
                  
  def background_url
    self.public_filename ? "/image/#{self.public_filename}" : nil
  end
  
end
