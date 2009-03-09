set :application, "sickcity"
set :scm, :git
set :repository,  "git://github.com/paulmwatson/sickcity.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

role :app, "paul@apps.diycity.org"
role :web, "paul@apps.diycity.org"
role :db,  "paul@apps.diycity.org", :primary => true