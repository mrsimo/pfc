class Thumbnail < ActiveRecord::Base
  has_attachment  :content_type => :image,
                  :processor => 'MiniMagick',
                  :storage => :file_system,
                  :path_prefix => "/document_thumbnails/"
end
