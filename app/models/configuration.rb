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
