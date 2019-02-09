FROM ruby:2.5-slim

RUN mkdir -p /usr/share/hurracloud/jawhar
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libmagic-dev libsqlite3-dev sqlite3
RUN apt-get install -y openjdk-8-jre tesseract-ocr libtesseract-dev usbutils inotify-tools udev ssh-client ntfs-3g cron

WORKDIR /usr/share/hurracloud/jawhar
COPY jawhar/Gemfile .
COPY jawhar/Gemfile.lock .
RUN bundle install
COPY ./jawhar/ ./

CMD ./bin/start_jawhar.sh
