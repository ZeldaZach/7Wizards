set :application, "7wizards.xxx.com"
set :domain, "7wizards.xxx.com"
set :deploy_to, "/data/var/www/7wizards"
set :port, 951

set :rails_env,  'test'

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{current_path} && /usr/bin/whenever --update-crontab #{application}"
  end
end

