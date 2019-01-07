#!/bin/bash

## Startup API Server
echo "Starting up API server"
rails s -p 3000 -b '0.0.0.0' -d
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start API server: $status"
  exit $status
fi

## Startup Zahif Mounter
echo "Starting up Zahif mounter"
bundle exec sidekiq -q mounter -d -L log/mounter.log
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Zahif Mounter: $status"
  exit $status
fi


## Startup USB Monitor
echo "Starting up USB monitor"
./bin/device_monitor.sh &> log/usb_monitor.log &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start USB monitor: $status"
  exit $status
fi

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
