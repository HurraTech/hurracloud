FROM alpine:3.8
RUN mkdir -p /usr/share/hurracloud
RUN apk add unzip inotify-tools openjdk8
RUN apk add tesseract-ocr \
        -X http://mirror.math.princeton.edu/pub/alpinelinux/edge/community \
        -X http://mirror.math.princeton.edu/pub/alpinelinux/edge/main

WORKDIR /usr/share/hurracloud/indexer
ADD indexer ./

CMD sh start.sh