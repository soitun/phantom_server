require 'yaml'
CONFIG = YAML.load_file('config/server.yml')

# --------------------------------------------------
# Bundler integration - supplies bundle:install task
# --------------------------------------------------
require "bundler/capistrano"

# -------------------------------------------
# Stages settings - allows cap [stage] deploy
# -------------------------------------------
set :stages, %w(production qa)
set :default_stage, :qa
require 'capistrano/ext/multistage'

# -------------------------------------------
# Fetching EC2 instances from AWS by tags
# -------------------------------------------
require 'cap-aws-ec2'
set :aws_key_id, CONFIG['aws_key_id']
set :secret_access_key, CONFIG['secret_access_key']
set :aws_region, CONFIG['aws_region']
set :ec2_project, CONFIG['ec2_project']
set(:ec2_env) { stage }

# -------------------------------------------
# ERB templates configuration
# -------------------------------------------
require 'cap-templates'
set :erb_templates, ['god/phantom_monitor.rb.erb' ,'phantom_monitor.yml.erb', 'nginx.conf.erb', 'response_test.html.erb', 'rndrme.js.erb']

# -------------------------------------------
# Git and deploytment details
# -------------------------------------------
set :application, 'Phantom-Server'
set :repository, CONFIG['repository']
set :scm, :git
set :deploy_via, :remote_cache
set :user, CONFIG['deploy_user']
set :deploy_to, CONFIG['deploy_to']
set :branch, fetch(:branch, "master")
set :use_sudo, false
set :nginx_conf, "/etc/nginx/sites-enabled/phantom_server"
set :phantom_base_port, 8002
set :phantom_ready_event, "renderReady"
set :phantom_process_check_host, "localhost"
set :phantom_process_check_url, "/response_test.html"
set :phantom_process_check_phrase, "Test is OK"
set :normalize_asset_timestamps, false
ssh_options[:paranoid] = false
default_run_options[:on_no_matching_servers] = :continue
# -------------------------------------------

# -------------------------------------------
# Tasks Definitions
# -------------------------------------------

namespace :phantomjs do
  desc "start phantom manager"
  task :start, roles: :web do
    run "cd #{current_path} && sudo bundle exec god -c config/god/phantom_monitor.rb"
  end

  desc "terminate god and phantom manager"
  task :stop, roles: :web do
    run "cd #{current_path} && sudo bundle exec god terminate" 
    run "ps ax | grep phan | grep -v grep | awk '{print $1}' | xargs -r sudo kill"
  end

  desc "restart phantomjs monitor"
  task :restart, roles: :web do
    run "cd #{current_path} && sudo bundle exec god restart phantom_monitor" 
  end

  desc "terminate god + phantom and restart them"
  task :hard_restart, roles: :web do
    stop
    start
  end
end

namespace :nginx do
  desc "Symlinks nginx configuration to current version"
  task :symlink, roles: :web, except: {no_release: true} do
    sudo "ln -sf #{current_path}/config/nginx.conf #{nginx_conf}"
  end

  desc "Reload nginx with current configuration"
  task :reload, roles: :web, except: {no_release: true} do
    sudo "service nginx reload"
  end
end

namespace :process_check_html do
  desc "Symlinks phantom process check html"
  task :symlink, roles: :web, except: {no_release: true} do
    sudo "ln -sf #{current_path}/config/response_test.html #{current_path}/public/response_test.html"
  end
end

namespace :deploy do

  task :start do
    phantomjs.start
    nginx.symlink
    process_check_html.symlink
    nginx.reload
  end

  task :restart do
    process_check_html.symlink
    nginx.symlink
    nginx.reload
    phantomjs.restart
  end

end
