class GroupsController < ApplicationController
  before_filter :login_required
  
  in_place_edit_for :group, :description
  
  def new
    @group =  Group.new
  end
  
  def create
    if params[:group][:name].blank?
      flash[:bad] = "You must name your group."
      redirect_to :action => :new
      return
    end
    
    group = Group.new(params[:group])
    group.owner_id = current_user.id
    flash[:notice] = "Group created correctly" if group.save
    
    mem = Membership.new :user_id => current_user.id, :group_id => group.id, :admin => true
    mem.save
    
    redirect_to :action  => :view, :id => group
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
  
  def delete
    Group.find(params[:id]).destroy
    @groups = Group.find :all
    redirect_to :controller => "website"
  end
  
  def get_description
    render :text => Group.find(params[:id]).description(:source)
  end
  
  def update_description
    g = Group.find(params[:id])
    g.update_attribute(:description, params[:value])
    g.reload
    render :text => RedCloth.new(g.description).to_html
  end
  
  def invite
    emails = params[:users].split("\n")
    @log = Array.new
    if emails
      for email in emails
        user = User.find_by_email(email)
        if user
          # Possible problems, the user is already a member, or has another invitation
          if Invitation.find_by_target_id(user.id)
            @log << "#{email} already has an invitation for this group. He just has to accept it!"
          elsif Membership.find_by_user_id_and_group_id(user.id,params[:id])
            @log << "#{email} is already a member of this group :)"
          else
            inv = Invitation.new :target_id => user.id, :source_id => current_user.id, :group_id => params[:id]
            @log << "#{email} has received an invitation" if inv.save
          end
        else
        @log << "#{email} isn't a member of drawme yet. He should signup."
        end
      end
    end
    flash[:log] = @log
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
  
  def promote
    @group = Group.find(params[:id])
    params[:users].each do |key,val|
      membership = @group.membership(key).update_attribute(:admin, true)
    end if @group.is_admin? current_user and not params[:users].blank?
    render :partial => "members"
  end
  
  def unpromote
    @group = Group.find(params[:id])
    puts params[:users].to_yaml
    params[:admins].each do |key,val|
      membership = @group.membership(key).update_attribute(:admin, false) unless @group.is_owner? User.find(key)
    end if @group.is_owner? current_user and not params[:admins].blank?
    render :partial => "members"
  end
end
