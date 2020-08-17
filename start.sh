#!/bin/bash
export HOSTNAME=$(hostname)
docker-compose -f docker-compose.yml up -d
