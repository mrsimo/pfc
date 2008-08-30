# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_image(element) # The element should have the public_filename function
    render :file => Page.find(4).public_filename
  end
  
  def problem(text)
    flash[:notice] = text
    flash[:type] = "bad"
  end
  
  def textile(text)    
    RedCloth.new(text).to_html
  end
  
end
