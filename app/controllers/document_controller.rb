class DocumentController < ApplicationController

  before_filter :login_required, :except => [ :image, :export ]
  before_filter :authorized?, :only => [ :image, :export ]
  
  def new
    @doc = Document.new
  end
  
  def create
    doc = Document.new params[:document]
    doc.user_id = current_user.id
    doc.save
    
    redirect_to :controller => "document", :action => "edit", :id => doc.id
  end
  
  def edit
    @doc = Document.find(params[:id])
  end
  
  def update
    doc = Document.find(params[:id])
    doc.update_attributes params[:document]
    
    # We have to check if the whole pages stuff needs changing
    if !doc.has_file and !doc.pages.first.filename.nil?
      create_blank_pages doc
    elsif doc.has_file and doc.pages.first.filename.nil?
      create_pages_from_file doc, params[:file]
    end
  end
  
  def draw
    @document = Document.find(params[:id])
    render :layout => false
  end
  
  def add_element
    doc = Document.find(params[:id])
    element = Element.create(:attr => params[:attr], :page_id => doc.get_current_page.id)
    render :text => "#{element.id}"
  end
  
  def remove_element
    Element.find(params[:id]).destroy
    render :text => "OK"
  end

  def list_elements
    doc = Document.find(params[:id])
    @current_page = doc.get_current_page
    @elements = @current_page.elements
    @object = Hash.new
    @object["page_num"] = @current_page.number
    @object["page_id"] = @current_page.id
    @object["elements"] = @elements
    render :layout => false
  end

  def change_page
    doc = Document.find(params[:id])
    doc.current_page = params[:page]
    doc.save
    render :text => "#{doc.get_current_page.id}"
  end
  
  # Safe way to have only the adequate people access images. Images are in an unaccessible path
  # and they are read and transmited from that file directly.
  def image
    @p = Page.find(params[:page])
    @f = File.open @p.image.public_filename(params[:thumb]) if !@p.image.filename.nil? and params[:page] != "undefined"
    render :layout => false
  end

  def remove_all_pages
    @doc = Document.find(params[:doc])
    @doc.pages.each {|p| p.destroy}
    flash[:notice] = "Pages removed."
    redirect_to :action => 'edit', :id => @doc.id
  end
  
  def add_blank_pages
    (1..params[:number].to_i).each do |page_num|
      Page.create :number => page_num, :document_id => params[:doc]
    end
    @doc = Document.find(params[:doc])
    @doc.height = params[:height]
    @doc.width = params[:width]
    @doc.save
    render :partial => 'pages'
  end
  
  def add_pages_from_file
    require 'action_controller'
    require 'action_controller/test_process.rb'
    require 'mime/types'
    require 'find'
    # We have a file that we have to work with
    # First we extract it to a temporal directory 
    extract_dir = "document_temp/#{Time.now.to_i.to_s}"
    Dir.mkdir extract_dir
    file = params[:file]
    puts params[:file]
    ext = File.extname(file.original_filename)
    
    # but we have to do it differently depending on the format :)
    case ext
      when ".zip"
        puts `unzip #{file.path} -d #{extract_dir}`
      when ".gz"
        puts `tar xzf #{file.path} -C #{extract_dir}`
      when ".rar"
        puts `unrar-free #{file.path} #{extract_dir}`
      when ".pdf"
        `convert -density 100 #{file.path} #{extract_dir}/im.jpg`
      else
        flash[:notice] = "We don't accept that type of file, sorry :("
        flash[:type] = "bad"
        redirect_to :action => "new"
        return
    end
    
    # Now we have to create the Page's with them. For that, we
    # explore the directory recursivelly.      
    files = Array.new
    Find.find(extract_dir) do |path|
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
    
    @doc = Document.find params[:id]
    
    files.each_with_index do |f,i|
      p = Page.create :number => i+1, :document_id => @doc.id
      Image.create  :uploaded_data => ActionController::TestUploadedFile.new("#{f}", MIME::Types.type_for(f)),
                :page_id => p.id
    end
    
    # Now just remove the temporary files :)
    FileUtils.rm_rf extract_dir   
    
    redirect_to :action => 'edit', :id => @doc.id
  end
end
