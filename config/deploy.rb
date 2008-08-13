set :application, "simo.ws"
set :user, "simo"
set :use_sudo, false
set :repository,  "svn://simo.ws/drawme"

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

set :deploy_via, :copy
set :synchronous_connect, true
set :runner, user

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end