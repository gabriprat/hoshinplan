#web: bundle exec rails server -p $PORT
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
clock: bundle exec clockwork app/clock.rb
worker:  bundle exec rake jobs:work

