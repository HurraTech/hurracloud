#!/bin/bash

docker-compose up -d --scale zahif=0 && sudo rm -fv data/db/db.sqlite3 && docker-compose exec redis redis-cli -n 0 FLUSHALL &&  sudo rm -rfv data/indices/* && curl -XDELETE localhost:9200/*  && docker-compose restart jawhar && docker-compose up -d --scale zahif=1 --scale jawhar=1
