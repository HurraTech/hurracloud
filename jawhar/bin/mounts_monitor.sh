./bin/files_monitor.sh &> log/files_monitor.log &
PID=$!
inotifywait -m /usr/share/hurracloud/mounts -e attrib --format "%e %w%f" | while read action path file; do
    echo "${action}: ${path}${file}"
    echo "Start new Files Monitor"
    ./bin/files_monitor.sh &> log/files_monitor.log &
    NEW_PID=$!

    echo "Kill old Files Monitor (process $PID)"
    pkill -P $PID
    PID=$NEW_PID
done