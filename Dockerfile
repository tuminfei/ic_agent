FROM ruby:2.7.8-alpine3.16

ENV BUILD_PACKAGES curl-dev build-base

RUN apk update && \
    apk upgrade && \
    apk add git curl $BUILD_PACKAGES

WORKDIR /usr/src/app

COPY . .

RUN gem install bundler:2.2.13 && \
    bundle install && \
    rake install:local

CMD ["sh"]