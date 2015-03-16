#!/bin/bash

heroku pgbackups:capture --expire --app hoshinplan
heroku pgbackups:restore DATABASE `heroku pgbackups:url --app hoshinplan` --app hp-staging

