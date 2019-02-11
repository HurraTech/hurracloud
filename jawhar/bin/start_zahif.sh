#!/bin/bash

## Startup Zahif Indexer
echo "Starting up Zahif Batch Indexer" 
PIDFILE=/var/resque.pid BACKGROUND=yes QUEUE=indexer rake resque:work
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Zahif Indexer: $status"
  exit $status
fi

echo "Starting up Zahif Single File Indexer" 
PIDFILE=/var/resque-single.pid BACKGROUND=yes QUEUE=single_file_indexer rake resque:work
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Zahif Single File Indexer: $status"
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
