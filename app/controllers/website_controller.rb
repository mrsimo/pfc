class WebsiteController < ApplicationController
  before_filter :login_required, :only => [ :panel ]
  
  def index
    redirect_to :action => "panel" if logged_in?
  end
  
  def panel
    
  end
  
  def list_public
    @docs = Document.find_all_by_public true
  end
  
  def find_public
    @docs = Search.documents.with(params[:s])
    @docs.reject!{|d| d.can_be_seen_by(current_user)}
  end
  
  # For ajax checking
  def user_exist
    @u = User.find_by_sql ["SELECT * FROM users WHERE upper(login) LIKE ?", params[:user]]
    render :text => @u ? @u.id.to_s : "0"
  end
  
end
