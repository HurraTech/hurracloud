FROM ruby:2.5-slim-stretch as build

RUN mkdir -p /usr/share/man/man && mkdir -p /usr/share/man/man1
#RUN apt-get update -qq && \
#    apt-get install -y build-essential libpq-dev nodejs libmagic-dev libsqlite3-dev sqlite3

RUN apt-get update && \
    apt-get install -y build-essential libmagic-dev sqlite3 libsqlite3-dev

RUN mkdir -p /usr/share/hurracloud/jawhar
WORKDIR /app
COPY jawhar/Gemfile .
COPY jawhar/Gemfile.lock .
RUN bundle install
COPY ./jawhar/ ./

### Runtime Image ###
FROM ruby:2.5-slim-stretch

RUN mkdir -p /usr/share/man/man && mkdir -p /usr/share/man/man1
RUN apt-get update && \
    apt-get install --no-install-recommends -y openjdk-8-jre tesseract-ocr \
                                               usbutils inotify-tools udev \
                                               ntfs-3g cron pkg-config sysstat sqlite3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app .
CMD ./bin/start_jawhar.sh
