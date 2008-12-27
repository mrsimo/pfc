# == Schema Information
# Schema version: 20081122123130
#
# Table name: pages
#
#  id          :integer(11)     not null, primary key
#  number      :integer(11)     not null
#  document_id :integer(11)     not null
#  created_at  :datetime        
#  updated_at  :datetime        
#  cursorx     :integer(11)     
#  cursory     :integer(11)     
#  cursorr     :integer(11)     
#

class Page < ActiveRecord::Base
  has_many :elements, :dependent => :destroy
  belongs_to :document
  has_one :image, :dependent => :destroy
                  
  def background_url
    self.public_filename ? "/image/#{self.public_filename}" : nil
  end
  
  def cursor
    {:r => cursorr, :x => cursorx, :y => cursory}
  end
  
end
