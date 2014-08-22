# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rrw::Application.load_tasks

# Require the reporter in your Rakefile, and ensure that ci:setup:minitest is a dependency of your minitest task:
require 'ci/reporter/rake/minitest'
task :test => 'ci:setup:minitest'
