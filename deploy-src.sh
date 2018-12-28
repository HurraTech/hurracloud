#!/bin/sh
alias run_rsync='rsync -azvP --chown root:root --filter=":- .gitignore" --exclude .git "./" root@192.168.1.2:/usr/local/src/hurracloud/' 
ssh root@192.168.1.2 'mkdir -p /usr/local/src/hurracloud/samaa/build'
run_rsync
ssh root@192.168.1.2 'ln -s /usr/share/hurracloud/* /usr/local/src/hurracloud/dev-volumes/usr/share/hurracloud/'
run_rsync; fswatch -o . | while read f; do run_rsync; done
