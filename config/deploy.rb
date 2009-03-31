set :user, ENV["USER"]
set :application, 'app-for-america'

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

# set :apache_ssl_enabled, true
# set :apache_modules_enabled, %w(rewrite ssl proxy_balancer proxy_http deflate headers proxy)

set :domain, "tweettracking.com"

# Update these if you're not running everything on one host.
role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :deploy_to, "/var/www/apps/#{application}"
# set :deploy_via, :copy

# set :remote_repo_location, "/home/git/tweettracker.com.git"
# set :pull_from, remote_repo_location
set :repository, "git://github.com/collin/app-for-america.git"
# set :deploy_via, :remote_cache
set :branch, "master"
# set :use_sudo, false
# set :git_shallow_clone, 1
 
# after 'deploy:symlink', 'deploy:mkdir_caching'
after 'deploy:symlink', 'deploy:symlink_secrets'
after 'deploy:symlink', 'deploy:symlink_log_files'

namespace :deploy do
  task :symlink_secrets do
    run "ln -s #{deploy_to}/shared/secrets.yml #{deploy_to}/current/config/secrets.yml"
  end

  task :symlink_log_files do
    run "ln -s #{deploy_to}/shared/log #{deploy_to}/current/log; true && touch #{deploy_to}/current/log/production.log"
  end
  
  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
  
  task :start do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
  
  task :mkdir_caching do
    run "mkdir #{deploy_to}/current/public/candidates"
  end
  
  task :migrate do
    run "cd #{deploy_to}/current && rake MERB_ENV=production  db:autoupgrade"
  end
end
