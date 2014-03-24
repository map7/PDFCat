rails_env = "production"

# Only install production gems
set :bundle_without, [:development, :test]

set :application, "pdfcat"
set :repository,  "ltsp.lan:/home/map7/pdfcat"

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
  run "#{try_sudo} chmod -R +x #{current_path}/"
  run "touch #{current_path}/tmp/restart.txt"
end

namespace :submodules do 
  task :init, :roles => :app do
    js_dir = "public/javascripts"
    
    # Initialise submodules
    run "cd #{current_path}; git submodule update -i #{js_dir}/jquery.beeline/"
    run "cd #{current_path}; git submodule update -i #{js_dir}/jquery.depechemode/"
    run "cd #{current_path}; git submodule update -i #{js_dir}/jquery.overdrive/"
    run "cd #{current_path}; git submodule update -i #{js_dir}/livequery/"
    run "#{try_sudo} chmod -R +x #{current_path}/"
  end
end

# For delayed job
namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :app do
    run "cd #{release_path}; #{try_sudo} RAILS_ENV=#{rails_env} script/delayed_job stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; #{try_sudo} RAILS_ENV=#{rails_env} script/delayed_job start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path}; #{try_sudo} RAILS_ENV=#{rails_env} script/delayed_job restart"
  end
end

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart",   "submodules:init"
after "deploy:restart", "delayed_job:restart"

# Bundler
namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(release_path, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :install, :roles => :app do
    run "cd #{release_path} && #{try_sudo} bundle install"
  end

  task :bundle_new_release, :roles => :db do
    bundler.create_symlink
    bundler.install
  end
end

after "deploy:update_code", "bundler:bundle_new_release"

# Currently have to do this manually
# # Update gems 
# namespace :gems do
#   desc "Install required gems"
#   task :install, :roles => :app do
#     run "cd #{release_path} && sudo rake gems:install"

#     on_rollback do
#       if previous_release
#         run "cd #{previous_release} && sudo rake gems:install"
#       else
#         logger.important "no previous release to rollback to, rollback of gems:install skipped"
#       end
#     end
#   end
# end

# before "deploy:assets:precompile", "gems:install"
# after "deploy:rollback:revision", "gems:install"
# after "deploy:update_code", "gems:install"
