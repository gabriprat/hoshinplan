#web: bundle exec rails server -p $PORT
web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
#web: bundle exec rainbows -p $PORT -c ./config/rainbows.rb
#web: bundle exec puma -C config/puma.rb
worker: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 bundle exec rake resque:work
clock: bundle exec clockwork lib/clock.rb
