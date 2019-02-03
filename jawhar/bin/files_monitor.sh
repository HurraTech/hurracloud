inotifywait -r -m /usr/share/hurracloud/mounts -e delete -e close_write | while read path action file; do
    echo "New event. ${path} .. ${action} .. ${file}"
done
