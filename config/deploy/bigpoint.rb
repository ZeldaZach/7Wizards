set :application, "7wizards"
set :domain, xxx
set :deploy_to, "/var/www/7wizards"
set :port, 22

role :web, domain                                       #for multi deployment
role :app, xxx
role :db,  domain, :primary => true

set :rails_env,  'production'

default_run_options[:pty] = true
ssh_options[:keys] = %w(keys/wizards_key.pem)
ssh_options[:paranoid] = false

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{current_path} && /opt/ruby-enterprise-1.8.7-2010.02/bin/whenever --update-crontab #{application}"
  end
end