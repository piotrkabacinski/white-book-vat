FROM ruby:2.7.0-alpine3.11

ENV HOME=/home/app

WORKDIR $HOME

# https://github.com/gliderlabs/docker-alpine/issues/53#issuecomment-179486583
RUN apk add --update \
  bash \
  build-base \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev \
  && rm -rf /var/cache/apk/*

COPY . $HOME/$APP_NAME/

RUN bundle install

WORKDIR $HOME/$APP_NAME
