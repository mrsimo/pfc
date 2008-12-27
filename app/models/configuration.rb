# == Schema Information
# Schema version: 20081122123130
#
# Table name: configurations
#
#  id           :integer(11)     not null, primary key
#  name         :string(255)     
#  description  :string(255)     
#  permalink    :string(255)     
#  value        :text            
#  content_type :string(255)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Configuration < ActiveRecord::Base
  
  has_permalink :name
  
  def self.get(permalink)
    begin
      if config = Configuration.find_by_permalink(permalink)
      
      if config.content_type == 'number'
        config.value.to_i
      elsif config.content_type == 'boolean'
        if config.value == 'false' or config.value == '0'
          false
        else
          true
        end
      elsif config.content_type == 'list'
        config.value.split(",").collect { |v| v.strip }
      elsif config.content_type == 'random'
          config.value.split(",").collect { |v| v.strip }.rand
      else
        config.value
      end
    end
    rescue Exception => e
      e
    end
  end
  
end
