#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'resque/tasks'
require 'rake/dsl_definition'
require 'rake'

require File.expand_path('../config/application', __FILE__)

Hoshinplan::Application.load_tasks
