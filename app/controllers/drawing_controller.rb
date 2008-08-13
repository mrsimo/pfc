class DrawingController < ApplicationController
  
  def index
    @document = Document.find(params[:id])
    @pages = Page.find(:all, :conditions => {:document_id => params[:id]})
    @current_page = Page.find(:first, :conditions => { :document_id => params[:id], :number => @document.current_page })
  end
  
end
