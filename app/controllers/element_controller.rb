class ElementController < ApplicationController
  layout "drawing"
  def add
    @doc = Document.find(params[:id])
    @current_page = Page.find(:first, :conditions => {:document_id => params[:id], :number => @doc.current_page})
    @element = Element.new(:attr => params[:attr], :page_id => @current_page.id )
    @result = @element.save
    session[:last] = @element
  end

  def list # List everything!
    
    @doc = Document.find(params[:id])
    @current_page = Page.find(:first, :conditions => {:document_id => @doc.id, :number => @doc.current_page})
    @elements = Element.find(:all, :conditions => { :page_id => @current_page.id } )
     
  end # list

  def new # List only the NEW stuff!!!
    @doc = Document.find(params[:document])
    @page = Page.find(:first,:conditions=> {:document_id => @doc.id, :number => params[:page]})
    
    if !session[:last]  # First time to ask for elements, or just asking for them all
      @elements = Element.find(:all, :conditions => {:page_id => @page.id})
      session[:last] = @elements[0] if @elements.length > 0
    else  # We have visited already. Only send new ones
      @elements = Element.find(:all, :conditions => 
                  ["page_id = ? AND created_at > ? AND id != ?", 
                  @page.id, session[:last][:created_at], session[:last][:id]])
    end
    if @elements.length > 0
      for el in @elements do
          session[:last] = el if session[:last][:created_at] < el.created_at
      end
    end
    
  end # new

  def remove # /element/remove/:id
    Element.find(params[:id]).destroy
  end # remove
  
  def change_page #
    
    @document = Document.find(params[:id])
    @document.current_page = params[:page]
    @document.save
    
    @current_page = Page.find(:first, :conditions => {:document_id => @document.id, :number => params[:page]})
  end
  
end
