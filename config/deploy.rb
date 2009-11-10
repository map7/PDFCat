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
  run "touch #{current_path}/tmp/restart.txt"
end
