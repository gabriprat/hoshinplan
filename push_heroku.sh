#!/bin/bash
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake assets:clean
RAILS_ENV=production bundle exec rake app:precompile_error_templates
git add public/assets
git commit -m assets public/assets/ 
git commit -m errors public/404.html public/422.html public/500.html
git push heroku master
