set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

default_run_options[:pty] = true
set :keep_releases, 5
set :application, "app"
set :user, "<user>"
set :use_sudo, true

set :scm, :git
set :repository,  "git@github.com:xxxxxxxxxxxxxxxxxxxx.git"
set :deploy_to, "/var/www/<document_root>"
