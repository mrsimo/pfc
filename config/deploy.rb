default_run_options[:pty] = true
set :repository,  "git@github.com:albertllop/pfc.git"
set :scm, "git"
set :application, "simo.ws"
set :user, "simo"
set :branch, "master"
set :git_shallow_clone, 1
ssh_options[:forward_agent] = true

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/simo/www/drawme"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, application
role :web, application
role :db,  application, :primary => true

set :deploy_via, :remote_cache
set :synchronous_connect, true
set :runner, user

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "After updating code we need to link the stuff that shouldn't update with updates..."
  task :after_update_code, :roles => :app do
    run "ln -s /home/simo/resources/drawme/database.yml #{release_path}/config/database.yml"
    run "ln -s /home/simo/resources/drawme/document_images #{release_path}/document_images"
    run "ln -s /home/simo/resources/drawme/document_temp #{release_path}/document_temp"
    run "ln -s /home/simo/resources/drawme/document_thumbnails #{release_path}/document_thumbnails"
  end
  
  
end

