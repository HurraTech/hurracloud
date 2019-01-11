#!/bin/bash

docker-compose up -d --scale zahif=0 && rm -v data/db.sqlite3 && docker-compose exec redis redis-cli -n 0 FLUSHALL && docker-compose exec jawhar sh -c "rake db:migrate && rake zahif:update" && rm -rfv indices/* && docker-compose up -d --scale zahif=1