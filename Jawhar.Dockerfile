FROM ruby:2.5-slim-stretch as build

RUN apt-get update && \
    apt-get install -y build-essential libmagic-dev sqlite3 libsqlite3-dev

WORKDIR /app
COPY jawhar/Gemfile .
COPY jawhar/Gemfile.lock .
RUN bundle config --global frozen 1 \
 && bundle install --without development test -j4 --retry 3 \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY ./jawhar/ ./
RUN rm -rf app/assets lib/assets vendor/assets app/helpers app/views/application.hmtl.erb

### Runtime Image ###
FROM ruby:2.5-slim-stretch

RUN mkdir -p /usr/share/man/man && mkdir -p /usr/share/man/man1
RUN apt-get update && \
    apt-get install --no-install-recommends -y openjdk-8-jre tesseract-ocr \
                                               usbutils inotify-tools udev libmagic-dev \
                                               ntfs-3g cron pkg-config sysstat sqlite3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY --from=build /app .

CMD ./bin/start_jawhar.sh
