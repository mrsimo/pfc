# == Schema Information
# Schema version: 20081101173132
#
# Table name: configurations
#
#  id              :integer(11)     not null, primary key
#  images_path     :string(255)     
#  thumbnails_path :string(255)     
#  temp_path       :string(255)     
#

# The Configuration model acts as the interface to the configurations table. 
# The configurations table should consist of only one row with one column for each configuration field in your system. 
#
# Callbacks prevent rows from being added to or removed from the table.
#
class Configuration < ActiveRecord::Base
  
    before_create :check_for_existing
    before_destroy :check_for_existing

   # class methods
   
   # Returns the system configuration record. You should use this instead of doing an explicit #find on this object, as this
   # method will retrieve only the first row from the table.
   #
   # If no configuration record exists, one will be created with blank fields.
   def self.load
      configuration = Configuration.find :first
       if configuration.nil?
         configuration = Configuration.create() 
       end
      configuration
   end
    
   protected
   
   # Prevents the destruction or creation of more than one record.
   def check_for_existing
        return false if Configuration.find(:all).size >= 1 
    end
end
