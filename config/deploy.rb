rails_env = "production"

set :application, "pdfcat"
set :repository,  "apps:/home/map7/pdfcat"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/usr/home/map7/webapps/pdfcat"

role :web, "paistram.lan"                          # Your HTTP server, Apache/etc
role :app, "paistram.lan"                          # This may be the same as your `Web` server
role :db,  "paistram.lan", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# In ur deploy.rb
deploy.task :restart, :roles => :app do
  run "chmod -R +x #{current_path}"
  run "touch #{current_path}/tmp/restart.txt"
end

# For delayed job
namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
  end
end

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"
