class Page < ActiveRecord::Base
  has_many :elements, :dependent => :destroy
  belongs_to :document
end
