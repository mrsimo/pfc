class GroupsController < ApplicationController
  before_filter :login_required
  
  def new
  end
  
  def create
    group = Group.new
    group.name = params[:name]
    group.description = params[:description]
    group.owner_id = current_user.id
    flash[:notice] = "Group created correctly" if group.save
    
    mem = Membership.new
    mem.user_id = current_user.id
    mem.group_id = group.id
    mem.save
    redirect_to :controller => "website", :action  => "panel"
  end

  def view
    @group = Group.find(params[:id])
    @members = Membership.find_by_sql(["SELECT * FROM users u, memberships m WHERE m.user_id = u.id AND m.group_id = ?", params[:id]])
  end
  
  def invite
    @group = Group.find(params[:id]) # This should be OK
    @user = User.find_by_sql ["SELECT * FROM users WHERE upper(login) LIKE ?", params[:user]] # This might not be ok
    if @user.length > 0
      inv = Invitation.new
      inv.invitator_id = current_user.id
      inv.user_id = @user[0].id
      inv.group_id = params[:id]
      flash[:notice] = "Invitation sent!" if inv.save
      redirect_to :controller => "website", :action => "panel"
    else
      flash[:notice] = "User not found, try again"
      redirect_to :action => "view", :id => params[:id]
    end
  end
  
  def accept # an invite
    # params :id es el id de la invitación
    i = Invitation.find params[:id]
    check_destinatary?(i)
    m = Membership.new
    m.user_id = i.user_id
    m.group_id = i.group_id
    flash[:notice] = "Invitation accepted" if m.save
    i.destroy
    redirect_to :action => "panel", :controller => "website"
  end
  
  def reject # an invite
    # params :id es el id de la invitacion
    i = Invitation.find params[:id]
    check_destinatary?(i)
    i.destroy
    flash[:notice] = "Invitation rejected"
    flash[:type] = "bad"
    redirect_to :action => "panel", :controller => "website"
  end
  
  protected
  
  def check_destinatary?(i)
    redirect_to :controller => "website" if i.user_id != current_user.id
  end
end
