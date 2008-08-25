# == Schema Information
# Schema version: 19
#
# Table name: pages
#
#  id          :integer(11)     not null, primary key
#  number      :integer(11)     not null
#  document_id :integer(11)     not null
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Page < ActiveRecord::Base
  has_many :elements, :dependent => :destroy
  belongs_to :document
  has_one :image, :dependent => :destroy
                  
  def background_url
    self.public_filename ? "/image/#{self.public_filename}" : nil
  end
  
end
