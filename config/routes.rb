ActionController::Routing::Routes.draw do |map|
  #Default one
  map.root :controller => "website", :action => "index"

  map.connect 'get_image/:user/:document/:image.:ext', :controller => "document", :action =>"get_image"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
  # If after everything there's nothing matching, it means we want to draw
  map.connect ':id', :controller => "drawing", :action => "index"
  
end
