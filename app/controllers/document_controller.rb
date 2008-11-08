class DocumentController < ApplicationController

  before_filter :login_required, :except => [ :image, :export, :draw, :list_elements ]
  before_filter :authorized?, :only => [ :image, :export ]
  
  def new
    @doc = Document.new
  end
  
  def create
    doc = Document.new params[:document]
    doc.user_id = current_user.id
    if doc.save
      redirect_to :controller => "document", :action => "edit", :id => doc.id
    else
      flash[:notice] = "There was some problem creating the document"
      redirect_to :action => "new"
    end
  end
  
  def edit
    @doc = Document.find(params[:id])
    get_out unless @doc.can_be_edited_by current_user
  end
  
  def update
    @doc = Document.find(params[:id])
    get_out unless @doc.can_be_edited_by current_user
    @doc.update_attributes params[:document]
    redirect_to :action => "edit", :id => @doc.id
  end
  
  def delete
    @doc = Document.find(params[:id])
    get_out unless @doc.can_be_deleted_by current_user
    @doc.destroy
    redirect_to :controller => 'website', :action => "panel", :reload => (rand*1000).to_i
  end
  
  def invite_user
    @doc = Document.find params[:id]
    @user = User.find :first, :conditions => ["login = upper(?)",params[:user].upcase]
    if @user
      @doc.users_with_access << @user unless @doc.users_with_access.include? @user
    else
      @error =  "User not found :("
    end
    render :partial => "users"
  end
  
  def invite_group
    @doc = Document.find params[:id]
    @group = Group.find params[:group]
    @doc.groups_with_access << @group unless @doc.groups_with_access.include? @group
    render :partial => "groups"
  end
  
  def uninvite_user
    @doc = Document.find(params[:id])
    @doc.users_with_access.delete User.find(params[:user])    
    render :partial => "users"
  end
  
  def uninvite_group
    @doc = Document.find(params[:id])
    @doc.groups_with_access.delete Group.find(params[:group])
    render :partial => "groups"
  end
  
  def toggle_user_perms
    @doc = Document.find(params[:id])
    @doc.toggle_user_perms(params[:user])
    render :partial => "users"
  end

  def toggle_group_perms
    @doc = Document.find(params[:id])
    @doc.toggle_group_perms(params[:group])
    render :partial => "groups"
  end

  def draw
    @document = Document.find(params[:id])
    if @document.pages.size > 0 and @document.can_be_seen_by current_user
      render :layout => false
    elsif @document.can_be_edited_by current_user
      redirect_to :action => 'edit', :id => @document
    else
      redirect_to :controller => 'website'
    end
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

  def save_cursor
    doc = Document.find(params[:id])
    p = doc.get_current_page
    p.cursorx = params[:x]
    p.cursory = params[:y]
    p.cursorr = params[:r]
    p.save
    render :text => "ok"
  end

  def list_elements
    doc = Document.find(params[:id])
    @current_page = doc.get_current_page
    @elements = @current_page.elements
    doc.ping current_user, request.remote_ip
    @object = Hash.new
    @object["page_num"] = @current_page.number
    @object["page_id"] = @current_page.id
    @object["elements"] = @elements
    @object["users"] = doc.recent_usernames
    @object["anonymous"] = doc.recent_anonymous_ips
    render :layout => false
  end

  def change_page
    doc = Document.find(params[:id])
    if params[:page].to_i > doc.pages.size
      id = 0
    else
      doc.current_page = params[:page]
      doc.save
      id = doc.get_current_page.id
    end
    render :text => "#{id}"
  end
  
  # Safe way to have only the adequate people access images. Images are in an unaccessible path
  # and they are read and transmited from that file directly.
  def image
    @p = Page.find(params[:page])
    @f = File.open @p.image.public_filename(params[:thumb]) if !@p.image.nil?  and !@p.image.filename.nil? and params[:page] != "undefined"
    render :layout => false
  end

  def remove_all_pages
    @doc = Document.find(params[:doc])
    @doc.pages.each {|p| p.destroy}
    flash[:notice] = "Pages removed."
    redirect_to :action => 'edit', :id => @doc.id
  end
  
  def add_1_page
    @doc = Document.find(params[:doc])
    p = Page.new :number => @doc.pages.size + 1
    p.document = @doc
    p.save
    @doc = Document.find(params[:doc])
    render :partial => 'pages'
  end
  
  def add_blank_pages
    @doc = Document.find(params[:doc])
    current_page = @doc.pages.size
    (1..params[:number].to_i).each do |page_num|
      Page.create :number => (page_num + current_page), :document_id => params[:doc]
    end

    render :partial => 'pages'
  end
  
  def add_page_from_file
    @doc = Document.find params[:id]
    p = Page.create :number => (@doc.pages.size+1), :document_id => @doc.id
    Image.create :uploaded_data => params[:file], :page_id => p.id
    @doc.update_needed_area
    redirect_to :action => 'edit', :id => @doc.id
    return
  end
  
  def add_pages_from_file
    require 'mime/types'
    # We have a file that we have to work with
    # First we extract it to a temporal directory 
    extract_dir = "document_temp/#{Time.now.to_i.to_s}"
    Dir.mkdir extract_dir
    file = params[:file]
    ext = File.extname(file.original_filename)
    # but we have to do it differently depending on the format :)
    if [".jpg",".jpeg",".gif",".png"].include? ext
      add_page_from_file
      return
    elsif [".zip",".gz",".rar",".pdf"].include? ext
      `mv #{file.path} #{extract_dir}/file#{ext}`
      t = Task.create :file => "file#{ext}", :dir => extract_dir, :document_id => params[:id]
      flash[:notice] = "The file has been queued for process. In a few moments it will be ready"
      redirect_to :action => "edit", :id => params[:id]
    else
      flash[:bad] = "We don't accept that type of file, sorry :("
      redirect_to :action => "edit", :id => params[:id]
      return
    end
  end
end
