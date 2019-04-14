#!/bin/sh
alias run_rsync='rsync -azvP --chown root:root --filter=":- .gitignore" --filter="P app-runner/server/HurraApp" --filter="P app-runner/client/src/HurraApp" --exclude data --exclude gdfuse --exclude apps --exclude appStore-temp --exclude indices --exclude logs --exclude mounts --exclude .git "./" root@172.16.0.99:/usr/local/src/hurracloud/ --delete' 
ssh root@172.16.0.99 'mkdir -p /usr/local/src/hurracloud/samaa/build'
run_rsync
ssh root@172.16.0.99 'ln -s /usr/share/hurracloud/zahif/* /usr/local/src/hurracloud/zahif/'

run_rsync; fswatch -o . | while read f; do run_rsync; done
