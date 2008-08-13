class Document < ActiveRecord::Base
  has_many :pages, :dependent => :destroy
  has_many :elements, :through => :pages
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
end
