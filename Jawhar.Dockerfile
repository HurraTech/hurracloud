FROM ruby:2.5-alpine
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /usr/src/jawhar
WORKDIR /usr/src/jawhar
COPY jawhar/Gemfile .
COPY jawhar/Gemfile.lock .
RUN bundle install
COPY ./jawhar/ ./jawhar/

CMD bundle exec rails s -p 3000 -b '0.0.0.0'
