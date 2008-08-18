class GroupsController < ApplicationController
  before_filter :login_required
  
  def new
    @group =  Group.new
  end
  
  def create
    group = Group.new(params[:group])
    group.owner_id = current_user.id
    flash[:notice] = "Group created correctly" if group.save
    
    mem = Membership.new :user_id => current_user.id, :group_id => group.id, :admin => true
    mem.save
    redirect_to :controller => "website", :action  => "panel"
  end

  def view
    @group = Group.find(params[:id])
  end
  
  def edit
    @group = Group.find(params[:id])
  end
  
  def update
    @group = Group.find(params[:id])
    flash[:notice] = "Grupo actualizado correctamente" if @group.update_attributes(params[:group])
    redirect_to :action => 'view', :id => @group.id
  end
  
  
  def invite
    user = User.find(:first, :conditions => ["upper(login) LIKE ?", params[:user]])
    if user
      # Possible problems, the user is already a member, or has another invitation
      if Invitation.find_by_target_id(user.id)
        flash[:notice] = "The user already has an invitation for this group! He just has to accept it :)"
      elsif Membership.find_by_user_id_and_group_id(user.id,params[:id])
        flash[:notice] = "The user is already a member of this group :)"
      else
        inv = Invitation.new :target_id => user.id, :source_id => current_user.id, :group_id => params[:id]
        flash[:notice] = "Invitation sent!" if inv.save
      end
    else
      flash[:notice] = "User not found, try again"
      flash[:type] = "bad"
    end
    redirect_to :action => "view", :id => params[:id]
  end
  
  def accept # an invite
    i = Invitation.find params[:id]
    m = Membership.new :user_id => i.target_id, :group_id => i.group_id
    flash[:notice] = "Invitation accepted" if m.save
    i.destroy
    redirect_to :action => "panel", :controller => "website"
  end
  
  def reject # an invite
    Invitation.find(params[:id]).destroy
    flash[:notice] = "Invitation rejected"
    redirect_to :action => "panel", :controller => "website"
  end
end
