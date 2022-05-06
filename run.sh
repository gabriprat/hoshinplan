#!/bin/bash

if [ "$1" == "/start" ]; then
  if [ "$2" == "web" ]; then
      exec bundle exec passenger start -p $PORT --max-pool-size 2  --nginx-config-template config/nginx.conf.erb $SSL_OPTS
  fi
  if [ "$2" == "worker" ]; then
      exec bundle exec env COUNT=3 VVERBOSE=1 TERM_CHILD=1 RESQUE_TERM_TIMEOUT=7 rake resque:work
  fi
  if [ "$2" == "clock" ]; then
      exec bundle exec clockwork lib/clock.rb
  fi
fi
