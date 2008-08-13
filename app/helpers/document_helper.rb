module DocumentHelper
  def get_groups
     @groups = Membership.find_by_sql(["SELECT * FROM groups g, memberships m WHERE m.group_id = g.id AND m.user_id = ?", current_user.id])
     ret = ""
     @groups.each {|g| ret += "<option>" + g.name + "</option>"}
     ret
  end
end
