#!/bin/bash

## Startup Zahif Indexer
echo "Starting up Zahif Indexer" 
PIDFILE=/var/resque.pid BACKGROUND=yes QUEUE=indexer rake resque:work
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Zahif Indexer: $status"
  exit $status
fi

## Startup Zahif Manager
echo "Starting up Zahif Manager"
QUEUE=manager-$(hostname) rake resque:work
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Zahif manager: $status"
  exit $status
fi
