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
  
  def editable_content(options)
     options[:content] = { :element => 'span' }.merge(options[:content])
     options[:url] = {}.merge(options[:url])
     options[:ajax] = { :okText => "'Save'", :cancelText => "'Cancel'"}.merge(options[:ajax] || {})
     script = Array.new
     script << "new Ajax.InPlaceEditor("
     script << "  '#{options[:content][:options][:id]}',"
     script << "  '#{url_for(options[:url])}',"
     script << "  {"
     script << options[:ajax].map{ |key, value| "#{key.to_s}: #{value}" }.join(", ")
     script << "  }"
     script << ")"

     content_tag(
       options[:content][:element],
       options[:content][:text],
       options[:content][:options]
     ) + javascript_tag( script.join )
   end
  
  
end
