FROM ruby:2.6.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY vendor /usr/src/app/vendor

RUN gem install bundler -v 1.17.3

RUN BUNDLE_PATH=$GEM_HOME bundle install --path vendor/cache --without test

COPY . .

ENTRYPOINT ["./bin/export"]
