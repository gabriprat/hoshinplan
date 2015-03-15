#!/bin/bash
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake assets:clean
RAILS_ENV=production bundle exec rake app:precompile_error_templates
git add public/assets
git commit -m assets public/assets/ 
git push heroku master
