set :user, 'deploy'
set :application, "sickcity.org"
set :scm, :git
set :repository,  "git@github.com:paulmwatson/sickcity.git"
after "deploy:update_code", "deploy:symlink_configs"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

role :app, application
role :web, application
role :db,  application, :primary => true

set :deploy_to, "/data/#{application}" 
set :use_sudo, false

# saves space by only keeping last 3 when running cleanup
set :keep_releases, 3 

# keeps a local checkout of the repository on the server to get faster deployments
set :deploy_via, :remote_cache

ssh_options[:paranoid] = false

# =============================================================================
# OVERRIDE TASKS
# =============================================================================
namespace :deploy do

  desc "Restart Passenger" 
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt" 
  end

  desc <<-DESC
    Deploy and run pending migrations. This will work similarly to the \
    `deploy' task, but will also run any pending migrations (via the \
    `deploy:migrate' task) prior to updating the symlink. Note that the \
    update in this case it is not atomic, and transactions are not used, \
    because migrations are not guaranteed to be reversible.
  DESC
  task :migrations do
    set :migrate_target, :latest
    update_code
    migrate
    symlink
    restart
  end

  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml
    CMD
  end

end