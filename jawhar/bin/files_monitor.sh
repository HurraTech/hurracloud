inotifywait -r -m /app/mounts -e delete -e close_write --format "%e %w%f" | while read action path file; do
    echo "${action}: ${path}${file}"
    rake zahif:index_file["${path}${file}"]
done
