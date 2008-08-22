class DocumentController < ApplicationController

  before_filter :login_required, :except => [ :image, :export ]
  before_filter :authorized?, :only => [ :image, :export ]
  
  def new
    @doc = Document.new
  end
  
  def create
    require 'action_controller'
    require 'action_controller/test_process.rb'
    require 'mime/types'
    require 'find'
    doc = Document.new params[:document]
    doc.user_id = current_user.id
    doc.save
    
    # Things to do:
    # Build the pages according to config_options
    if params[:config_options] == "blank"
      (1..params[:document][:num_pages].to_i).each do |page_num|
        Page.create :number => page_num, :document_id => doc.id       
      end
    else
      # We have a file that we have to work with
      # First we extract it to a temporal directory 
      extract_dir = "document_temp/#{Time.now.to_i.to_s}"
      Dir.mkdir extract_dir
      file = params[:file]
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
            
      files.each_with_index do |f,i|
        Page.create  :uploaded_data => ActionController::TestUploadedFile.new("#{f}", MIME::Types.type_for(f)),
                  :number => i+1, :document_id => doc.id
      end
    end
    redirect_to :controller => "website", :action => "panel"
  end
  
  def draw
    @document = Document.find(params[:id])
    render :layout => false
  end
  
  def add_element
    @doc = Document.find(params[:id])
    @current_page = Page.find(:first, :conditions => {:document_id => params[:id], :number => @doc.current_page})
    @element = Element.new(:attr => params[:attr], :page_id => @current_page.id )
    @result = @element.save
    session[:last] = @element
  end

  def list_elements # List everything!
    
    @doc = Document.find(params[:id])
    @current_page = Page.find(:first, :conditions => {:document_id => @doc.id, :number => @doc.current_page})
    @elements = Element.find(:all, :conditions => { :page_id => @current_page.id } )
     
  end # list

  def remove_element # /element/remove/:id
    Element.find(params[:id]).destroy
  end # remove
  
  def change_page #
    
    @document = Document.find(params[:id])
    @document.current_page = params[:page]
    @document.save
    
    @current_page = Page.find(:first, :conditions => {:document_id => @document.id, :number => params[:page]})
  end
  
  # Safe way to have only the adequate people access images. Images are in an unaccessible path
  # and they are read and transmited from that file directly.
  def image
    @p = Page.find(params[:page])
    @f = File.open(@p.public_filename(params[:thumb]))
    render :layout => false
  end
  
  
  
  
end
