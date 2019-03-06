#!/bin/sh
alias run_rsync='rsync -azvP --chown root:root --filter=":- .gitignore" --exclude appStore --exclude data --exclude gdfuse --exclude apps --exclude appStore-temp --exclude indices --exclude logs --exclude mounts --exclude .git "./" root@192.168.1.2:/usr/local/src/hurracloud/ --delete' 
ssh root@192.168.1.2 'mkdir -p /usr/local/src/hurracloud/samaa/build'
run_rsync
ssh root@192.168.1.2 'ln -s /usr/share/hurracloud/zahif/* /usr/local/src/hurracloud/zahif/'

run_rsync; fswatch -o . | while read f; do run_rsync; done
