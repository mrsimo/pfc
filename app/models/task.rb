# == Schema Information
# Schema version: 20081101173132
#
# Table name: tasks
#
#  id          :integer(11)     not null, primary key
#  file        :string(255)     
#  dir         :string(255)     
#  done        :boolean(1)      
#  document_id :integer(11)     
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Task < ActiveRecord::Base
  belongs_to :document
  
  def process
    require 'action_controller'
    require 'action_controller/test_process.rb'
    require 'mime/types'
    require 'find'
    
    ext = File.extname(self.file)
    directory = "#{ENV["PWD"]}/#{self.dir}"

    file = "#{directory}/#{self.file}"
    case ext
    when ".zip"
      puts `unzip #{file} -d #{directory}`
    when ".gz"
      puts `tar xzf #{file} -C #{directory}`
    when ".rar"
      puts `unrar-free #{file} #{directory}`
    when ".pdf"
      `convert -density 100 #{file} #{directory}/im.jpg`
    end
       
    `rm #{file}`
       
    # Now we have to create the Page's with them. For that, we
    # explore the directory recursivelly.      
    files = Array.new
    Find.find(directory) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?.
          Find.prune
        else
          next
        end
      else
        files << path
      end
    end
    # This is a smart piece of code to sort files even when we have a full path, and not 
    if ext == ".pdf"
      files.sort! {|aa,bb| a = File.basename(aa); b = File.basename(bb); (a[3..(a.size-5)].to_i) <=> (b[3..(b.size-5)].to_i); }
    else
      files.sort! {|aa,bb| File.basename(aa) <=> File.basename(bb)}
    end
    
    @doc = self.document
    current_pages = @doc.pages.size
    files.each_with_index do |f,i|
      puts "Processing #{f}"
      if [".jpg",".jpeg",".gif",".png"].include? File.extname(f)
        puts "OK!!"
        p = Page.create :number => (current_pages+i+1), :document_id => @doc.id
        Image.create :uploaded_data => ActionController::TestUploadedFile.new("#{f}", MIME::Types.type_for(f)), :page_id => p.id
      end
    end
    
    # Set the document's size automatically
    @doc.update_needed_area

    # Now just remove the temporary files :)
    FileUtils.rm_rf directory  
    self.done = true
    self.save    
  end
  
end
