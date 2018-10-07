
set :application, "7wizards.com"
set :repository,  "xxx"
set :scm, :git
set :deploy_via, :remote_cache


set :user, "deploy"
set :password, "deploy"

set :keep_releases, 3

set :domain, "7wizards.com"

set :deploy_to, "/var/www/7wizards"

role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :runner, nil
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:keys] = %w(keys/wizards_key.pem)
ssh_options[:paranoid] = false

ssh_options[:forward_agent] = true
set :use_sudo, true
set :normalize_asset_timestamps, false

#========================
#CUSTOM
#========================

before "deploy", "deploy:stop"

after "deploy:update",  "deploy:build_flash", "deploy:migrations"
after "deploy:update", "deploy:update_avatar_symlink", "deploy:update_crontab"
after "deploy", "deploy:cleanup", "deploy:start"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{current_path} && /opt/ruby-enterprise-1.8.7-2010.02/bin/whenever --update-crontab #{application}"
  end


  task :update_avatar_symlink, :except => { :no_release => true } do
    run "ln -s #{shared_path}/files/avatars #{current_path}/public/images/"
  end

  task :build_flash do
    run "ant -f #{current_path}/flash/build.xml"
  end

  task :start, :roles => :app do
    deploy.web.enable
  end

  task :stop, :roles => :app do
    deploy.web.disable
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

end

	