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
end
