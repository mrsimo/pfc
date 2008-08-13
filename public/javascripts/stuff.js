$(document).ready(function(){
	$("#user_finder_text").focus(function(){this.value =""});
	
	// Need an auxiliary function because it can happen from two different
	// events, clicking on Add or pressing intro.
	addUser = function() {
		user = $("#user_finder_text").val();
		$.get("/website/user_exist", {user: user}, function(response) {
			if(response == 0){
				$("#user_finder_messages").html("Sorry, the user " + user + " was not found.").attr("class","bad");
			}
			else {
				if( $("#select_people_list").html().indexOf(user) == -1 ) {
					$("#user_finder_messages").html("User " + user + " added to the list.").attr("class","good");
					$("#select_people_list").show();
					$("#select_people_list tbody").append("<tr id=\"" + user + "\"><td>" + user + "</td><td><input type=\"checkbox\" name=\"user[" + user + "]\" value=\"0\" /><a href=\"#\" onclick=\"remove(\'" + user + "\')\"><img src=\"/images/cross.png\" /></a></td></tr>");
					$("#users_list").val($("#users_list").val() + " " + user);
					$("#user_finder_text").val("");
				} else $("#user_finder_text").val("");
			}
		});
	};
	
	// Pressing Intro
	$("#user_finder_text").keypress(function(e){
		if (e.keyCode==13) {
			addUser();
			return false;
		}
	});
	// Clicking Add
	$("#user_finder_submit").click(function(e){
		addUser();
		return false;
	});

	$("#user_finder_remove").click(function(e){
		var select = $("#permissions div#select_people select").get()[0];
		select.options[select.selectedIndex] = null;
		return false;
	})
	
	$("#permissions form").submit(function(){
		
	});
	
});
// Remove
function remove(user){
	$("#" + user).remove();
}