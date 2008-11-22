# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

namespace :servers do
  desc "Reset to default configuration"
  task :reset => :environment do
    config = YAML::load(File.open("#{RAILS_ROOT}/config/mongrel_cluster.yml"))
    config["port"] = 3000
    config["servers"] = 2
    f = File.open "#{RAILS_ROOT}/config/mongrel_cluster.yml", "w"
    f.write(config.to_yaml)
    f.close
    puts "Configuration set to start 2 mongrels on ports 6000 and 6001"
    puts "run rake servers:start to start them"
  end
  
  desc "Set the configuration according to database"
  task :config => :environment do 
    config = YAML::load(File.open("#{RAILS_ROOT}/config/mongrel_cluster.yml"))
    port = Configuration.get("server-port")
    config["port"] = port unless port.nil?
    num = Configuration.get("server-instance-number")
    config["servers"] = num unless num.nil?
    f = File.open "#{RAILS_ROOT}/config/mongrel_cluster.yml", "w"
    f.write(config.to_yaml)
    f.close
    puts "Configuration set to start #{config["servers"]} mongrels starting on port #{config["port"]}"
    puts "run rake servers:start to start them"
  end
  
  desc "Start mongrel servers according to the current mongrel_cluster.yml"
  task :start => :environment do
    puts `mongrel_rails cluster::start`
  end
  
  desc "Stop running mongrel servers"
  task :stop => :environment do
    puts `mongrel_rails cluster::stop`
  end
  
  desc "Restart running mongrel servers"
  task :restart => :environment do
    puts `mongrel_rails cluster::restart`
  end
  
end
