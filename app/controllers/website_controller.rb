class WebsiteController < ApplicationController
  before_filter :login_required, :only => [ :panel ]
  
  def index
  end
  
  def panel
    @documents = Document.find(:all, :conditions => {:user_id => current_user.id})
    @groups = Membership.find_by_sql(["SELECT * FROM groups g, memberships m WHERE m.group_id = g.id AND m.user_id = ?", current_user.id])
    @invites = Invitation.find(:all, :conditions => {:user_id => current_user.id})
  end
  
  def user_exist
    @u = User.find_by_sql ["SELECT * FROM users WHERE upper(login) LIKE ?", params[:user]]
    render :layout => "drawing"
  end
  
end
