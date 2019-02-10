#!/bin/bash

docker-compose up -d --scale zahif=0 && docker-compose restart jawhar && rm -fv data/db/db.sqlite3 && docker-compose exec redis redis-cli -n 0 FLUSHALL && docker-compose exec jawhar sh -c "rake db:migrate && rake zahif:update" && rm -rfv data/indices/* && docker-compose up -d --scale zahif=2 --scale jawhar=1