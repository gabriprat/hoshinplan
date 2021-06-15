#webp: bundle exec rails server -p $PORT
#webu: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
#webr: bundle exec rainbows -p $PORT -c ./config/rainbows.rb
#web: bundle exec puma -C config/puma.rb
web: bundle exec passenger start -p $PORT --max-pool-size 2  --nginx-config-template config/nginx.conf.erb $SSL_OPTS
worker: env COUNT=3 VVERBOSE=1 TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 bundle exec rake resque:work
clock: bundle exec clockwork lib/clock.rb
