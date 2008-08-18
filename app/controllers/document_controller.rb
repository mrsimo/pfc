class DocumentController < ApplicationController
  require 'zip/zip'
  require 'fileutils'
  before_filter :login_required, :except => [ :image, :export ]
  before_filter :authorized?, :only => [ :image, :export ]
  
  # STEP ONE to create a document
  def new
  end
  
  # STEP TWO We browse the content of the file given, and show it to him. 
  # He also fills information about it (Title and Description)
  def confirm_content
    @file = params[:file]
        
    saveDir = "/rails/" + current_user.id.to_s
    session[:save_dir] = saveDir
    # Remove the previous files we could find there
    `rm -rf #{saveDir}/temp/*`
    `rm -rf #{saveDir}/thumbnails/*`
    `rm -rf #{saveDir}/extract/*`
    
    #Extract the compressed file / convert pdf
    extract(@file,saveDir)
    
    # Generate Thumbnails
    Dir.chdir(saveDir + "/temp/")
    Dir.foreach(".") { |f| `convert -thumbnail 80 #{saveDir}/temp/#{f} #{saveDir}/thumbnails/#{f}` }
    
    # Find the biggest image
    Dir.chdir(saveDir + "/temp/")
    @max = [0,0]
    Dir.foreach(".") do |f|
      if f != "." && f != ".."
        temp = `identify #{saveDir}/temp/#{f}`
        temp2 = temp.split
        size = temp2[2].split("x")
        (0..1).each {|i| @max[i] = size[i].to_i if size[i].to_i > @max[i]}
      end
    end
    @recommended = [@max[0]+200,@max[1]+200]
    @recommended[0] = 700 if @recommended[0] < 500
    @recommended[0] = 1000 if @recommended[0] < 800
    
    # We pass the file names to the view
    @files = Dir.entries(saveDir + "/temp/") - [".", "..", ".DS_Store"]
    @files.each{|f| f.downcase!}
    @files.sort!
        
  end
  
  # STEP THREE The stuff is created
  # The user decides who can visit this document and who can't
  def select_permissions
    flash[:notice] = "The document has created correctly! Now just one more step."
    n = 1
    @doc = Document.new
    @doc.title = params[:title]
    @doc.description = params[:description]
    @doc.num_pages = params[:files].values.length
    @doc.user_id = current_user.id
    @doc.height = params[:height]
    @doc.width = params[:width]
    @doc.save
    
    params[:files].values.sort!.each do |f|
      p = Page.new
      p.background = f
      p.document_id = @doc.id
      p.number = n
      n++
      flash[:notice] = "There was a problem creating the page" if !p.save
    end
    
    # remove the temp folder to the doc.id
    File.rename(session[:save_dir] + "/temp/", session[:save_dir] + "/" + @doc.id.to_s)
    Dir.mkdir("/rails/" + current_user.id.to_s + "/temp")
    
    @groups = Group.find_by_sql(["SELECT * FROM groups g, memberships m WHERE m.group_id = g.id AND m.user_id = ?", current_user.id])
    
  end
  
  # STEP FOUR The last settings are saved
  def create
    @d = Document.find_by_id params[:doc]
    if params[:who]=="everyone"
      @d.public = 1
      @d.public = 2 if params[:everyone_write]
      @d.save
    else
      @d.public = 0
      @d.save
      # Crear permissions para params[:users_list].split
      params[:users_list].split.each do |u|
        Permission.new(:target_type => 0, :target_id => User.find(:first,:conditions => {:login => u}),
                       :document_id => params[:doc].to_i, :permission => 0).save
      end if params[:users_list]
      # Crear permissions para params[:groups].value
      params[:groups].values.each do |g|
        Permission.new (:target_type => 1, :target_id => g, 
                       :document_id => params[:doc].to_i, :permission => 0).save
      end if params[:groups]
    end
    redirect_to :controller => "website", :action => "panel"
  end
  
  # Safe way to have only the adequate people access images. Images are in an unaccessible path
  # and they are read and transmited from that file directly.
  def image
    @p = Page.find(params[:page])
    @f = File.open(@p.public_filename(params[:thumb]))
    render :layout => false
  end
  
  # Delete a document. We need extra checking besides people being loged, to see if the one deleting
  # the document is the current owner.
  def delete
    doc = Document.find(params[:id])
    redirect_to :controller => "website", :action => "panel" if current_user.id != doc.user_id
    FileUtils.rm_r "/rails/" + doc.user_id.to_s + "/" + doc.id.to_s
    flash[:notice] = "Document removed" if doc.destroy
    redirect_to :controller => "website", :action =>"panel"
  end

  # We want to export the current board as a pdf file.
  def export
    # To do that, we convert every page into an image, then all of them into a pdf.
    @pags = Page.find(:all, :conditions => {:document_id => params[:id]})
    @pags.each{ |pag| convert_page(pag.id)}
    Dir.chdir "/rails/"
    `convert *.svg #{current_user.id.to_s}.pdf`
    @f= File.open("/rails/#{current_user.id.to_s}.pdf")
    render :layout => "drawing"
  end
  
protected

def authorized?
  true
end


def convert_page(page_id)
  p = Page.find page_id
  els = Element.find(:all, :conditions => {:page_id => page_id})
  d = Document.find(p.document_id)
  u = User.find(d.user_id)
  Dir.chdir "/rails/"
  f = File.new("export_" + page_id.to_s + ".svg","w+")
  
  f.write "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
  f.write "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
  f.write "<svg width=\"3500\" height=\"5000\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"
  size=`identify /rails/#{u.id}/#{p.document_id}/#{p.background}`.split[2].split("x")
  f.write "<image x=\"200\" y=\"100\" width=\"#{size[0]}\" height=\"#{size[1]}\" xlink:href=\"#{u.id}/#{p.document_id}/#{p.background}\"/>"
  
  els.each do |el|
    atributes = ActiveSupport::JSON.decode el.attr
    f.write get_svg(atributes)
  end
  
  f.write "</svg>"
  f.close
  
end

def get_svg(atributes)
  case atributes["type"]
  when "line"
    "<line style=\"fill:none; stroke: #{atributes["color"]}; stroke-width: #{atributes["thick"]}; stroke-opacity:#{atributes["fill"]};\"
      x1=\"#{atributes["x1"]}\" y1=\"#{atributes["y1"]}\" x2=\"#{atributes["x2"]}\" y2=\"#{atributes["y2"]}\" />\n"
  when "pencil"
    
    "<polyline style=\"fill:none; stroke: #{atributes["color"]}; stroke-width: #{atributes["thick"]}; stroke-opacity:#{atributes["fill"]};\"
    points=\"#{atributes["points"]}\"/>\n" unless atributes["points"].split.length < 2 # imagemagick doesnt like 1-point polylines
  when "square"
    "<rect style=\"fill:white; fill-opacity:0.4; stroke: #{atributes["color"]}; stroke-width: #{atributes["thick"]}; stroke-opacity:#{atributes["fill"]};\"
    height=\"#{atributes["height"]}\" width=\"#{atributes["width"]}\" x=\"#{atributes["x"]}\" y=\"#{atributes["y"]}\" />\n"
  when "circle"
    "<ellipse style=\"fill:white; fill-opacity:0.4; stroke: #{atributes["color"]}; stroke-width: #{atributes["thick"]}; stroke-opacity:#{atributes["fill"]};\"
    rx=\"#{atributes["rx"]}\" ry=\"#{atributes["ry"]}\" cx=\"#{atributes["x"]}\" cy=\"#{atributes["y"]}\" />\n"
  end
end

def extract(file,there)
  ext = File.extname(file.original_filename)
  case ext
    when ".zip"
      `unzip #{file.path} -d #{there}/extract/`
    when ".gz"
      `tar xzf #{file.path} -C #{there}/extract/`
    when ".rar"
      `unrar-free #{file.path} #{there}/extract/`
    when ".pdf"
      puts `convert -density 100 #{@file.path} #{there}/extract/im.jpg`
      Dir.chdir(there + "/extract")
      Dir.foreach(".") { |f| File.rename(f, f.gsub(/im\-([0-9]).jpg/, 'im-0\1.jpg')) unless f == "." || f==".." }
      Dir.foreach(".") { |f| File.rename(f, f.gsub(/im\-([0-9])([0-9]).jpg/, 'im-0\1\2.jpg')) unless f == "." || f==".." }
      Dir.foreach(".") { |f| File.rename(f, f.gsub(/im\-([0-9])([0-9])([0-9]).jpg/, 'im-0\1\2\3.jpg')) unless f == "." || f==".." }
  end
  copy(there + "/extract", there + "/temp")
end

def copy(from,to)
  accepted_extensions = [".png",".jpg",".gif",".bmp"]
  Dir.chdir(from)
  Dir.foreach(".") do |f|
    Dir.chdir(from)
    if File.directory?(f) && f != "." && f != ".."
      puts "exploring #{f}"
      copy(from + "/" + f,to)
    elsif accepted_extensions.include?(File.extname(f.downcase))
      Dir.chdir(from)
      puts "copying from #{from} to #{to}"
      `mv #{f} #{to}/#{f.downcase}`
    end
  end
end

end
