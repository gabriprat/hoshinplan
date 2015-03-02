#web: bundle exec rails server -p $PORT
#web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
#web: bundle exec rainbows -p $PORT -c ./config/rainbows.rb
web: bundle exec puma -C config/puma.rb
worker: rake jobs:work
clock: bundle exec clockwork lib/clock.rb
