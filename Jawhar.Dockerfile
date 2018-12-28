FROM ruby:2.5-slim

RUN mkdir -p /usr/share/hurracloud/jawhar
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libmagic-dev libsqlite3-dev

WORKDIR /usr/share/hurracloud/jawhar
COPY jawhar/Gemfile .
COPY jawhar/Gemfile.lock .
RUN bundle install
COPY ./jawhar/ ./

CMD rails s -p 3000 -b '0.0.0.0'
