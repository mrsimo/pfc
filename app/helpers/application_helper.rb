# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_image(element) # The element should have the public_filename function
    render :file => Page.find(4).public_filename
  end
  
  def problem(text)
    flash[:bad] = text
  end
  
  def textile(text)    
    RedCloth.new(text).to_html
  end
  
  def title(text)
    content_for(:title) {text}
  end
  
  def get_out
    redirect_to :controller => "welcome", :action => "index"
  end  
  
end
