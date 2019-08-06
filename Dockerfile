FROM ruby:2.5.5

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY vendor /usr/src/app/vendor

RUN BUNDLE_PATH=$GEM_HOME bundle install --path vendor/cache --without test

COPY . .

RUN bin/spring binstub --remove --all

ENTRYPOINT ["./bin/export"]
