module WebsiteHelper
  
  def show_invitation(invite)
    @group = Group.find(invite.group_id)
    @user = User.find(invite.invitator_id)
    "<p><strong>#{@user.login}</strong> has invited you to the group: <strong>#{@group.name}</strong>.
    Do you #{link_to 'accept', :controller => 'groups', :action => 'accept', :id => invite.id}, 
    #{link_to 'reject', :controller => 'groups', :action => 'reject', :id => invite.id}?</p>"
  end
  
end
