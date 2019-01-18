rake zahif:update

inotifywait -r -m /dev/bus/usb -e CREATE -e DELETE | while read e
do
    rake zahif:update
done
