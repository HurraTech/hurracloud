#!/bin/bash

# Persist host fingerprint
if [ ! -f /root/.ssh/known_hosts ]; then
    ssh-keyscan -H hurracloud >> /root/.ssh/known_hosts
fi

## Deploy Database migrations
echo "Deploy Database"
rake db:migrate
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to deploy DB migrations: $status"
  exit $status
fi


## Startup API Server
### Serves API requests on port 3000
echo "Starting up API server"
rails s -p 3000 -b '0.0.0.0' -d
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start API server: $status"
  exit $status
fi

## Startup background scheduler
### Scheduler is responsible for retrying failed jobs
echo "Starting up scheduler"
rake resque:scheduler &> log/scheduler.log &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start scheduler: $status"
  exit $status
fi

## Startup Zahif Mounter & Metadata Updater
### Mounter is responsible for processing mount and unmount jobs that are sent by Jawhar backend
### Metadata Updater simply changes status of index to paused or delete it (invoked after WorkerManager has completed descheduling, see WorkerManger)
echo "Starting up Zahif mounter" 
QUEUE=metadata_updates,mounter BACKGROUND=yes rake resque:work
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Zahif Mounter: $status"
  exit $status
fi

## Startup Zahif Files Monitor
### Mounts monitor responsible for spawning files monitor whenever there is new mount / unmount operations
### Files montior is responsible for enqueing index jobs when mounts have file changes
echo "Starting up Zahif mounts monitor" 
./bin/mounts_monitor.sh &> log/mounts_monitor.log &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Zahif Mounts Monitor: $status"
  exit $status
fi

## Startup USB Monitor
### USB monitor simply runs rake zahif:update command whenever there's change in system's USB devices
echo "Starting up USB monitor"
./bin/device_monitor.sh &> log/usb_monitor.log &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start USB monitor: $status"
  exit $status
fi

echo "Setup cron schedule"
echo "*/5 * * * * rake zahif:spawn_scanners" >> ~/cron
crontab ~/cron

service cron start

echo "Done. Monitoring processes "

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  ps aux | grep rails |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux | grep sidekiq |grep -q -v grep
  PROCESS_2_STATUS=$?
  ps aux | grep inotify |grep -q -v grep
  PROCESS_3_STATUS=$?

  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    echo "PROCESS_1_STATUS ${PROCESS_1_STATUS}"
    echo "PROCESS_2_STATUS ${PROCESS_2_STATUS}"
    echo "PROCESS_3_STATUS ${PROCESS_3_STATUS}"
    # exit 1
  fi
done
