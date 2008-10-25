class Task < ActiveRecord::Base
  belongs_to :document
  
  def process
    require 'action_controller'
    require 'action_controller/test_process.rb'
    require 'mime/types'
    require 'find'
    
    ext = File.extname(self.file)
    case ext
    when ".zip"
      puts `unzip #{self.dir}/#{self.file} -d #{self.dir}`
    when ".gz"
      puts `tar xzf #{self.dir}/#{self.file} -C #{self.dir}`
    when ".rar"
      puts `unrar-free #{self.dir}/#{self.file} #{self.dir}`
    when ".pdf"
      `convert -density 100 #{self.dir}/#{self.file} #{self.dir}/im.jpg`
    end
       
    # Now we have to create the Page's with them. For that, we
    # explore the directory recursivelly.      
    files = Array.new
    Find.find(self.dir) do |path|
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
      p = Page.create :number => (current_pages+i+1), :document_id => @doc.id
      Image.create :uploaded_data => ActionController::TestUploadedFile.new("#{f}", MIME::Types.type_for(f)), :page_id => p.id
    end
    
    # Set the document's size automatically
    @doc.update_needed_area
    
    # Now just remove the temporary files :)
    FileUtils.rm_rf self.dir  
    self.done = true
    self.save    
  end
  
end
