#!/bin/bash
export HOSTNAME=$(hostname)
docker-compose up -f docker-compose.yml up -d
