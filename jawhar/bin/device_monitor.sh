inotifywait -r -m /dev/bus/usb -e CREATE -e DELETE | while read e
do
    rake zahif_watcher:update_data_sources
done
