#!/bin/bash

heroku pgbackups:capture
curl -o latest.dump `heroku pgbackups:url`
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d hoshinplan_dev latest.dump 
rm latest.dump
