FROM ruby:2.6

RUN apt-get update
RUN apt-get install -y --no-install-recommends default-libmysqlclient-dev default-mysql-client
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle install --path vendor/cache --without test

COPY . .

ENTRYPOINT ["bundle", "exec", "./bin/exporter"]
