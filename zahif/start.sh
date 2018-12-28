#!/bin/sh
INDEXER_HOME=/usr/share/hurracloud/indexer
mkdir -p ${INDEXER_HOME}/indices
mkdir -p ${INDEXER_HOME}/logs
export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

for index in ${INDEXER_HOME}/indices/*
do
    index=${index%*/}
    index=${index##*/}
    [ "${index}" == "_default" ] && continue
    echo "Going to start indexer for index ${index}"
    bin/fscrawler --config_dir ${INDEXER_HOME}/indices ${index} --debug &> ${INDEXER_HOME}/logs/${index}
done

inotifywait -m ${INDEXER_HOME}/indices -e create |
    while read path action file; do
        echo "Running indexer for '$file' (appeared in directory '$path' via '$action') "
        bin/fscrawler --config_dir ${INDEXER_HOME}/indices
    done
