FROM ruby:2.2.3

ENV LANG=C.UTF-8

COPY Gemfile* /tmp/
WORKDIR /tmp
ENV BUNDLE_GEMFILE=/tmp/Gemfile BUNDLE_JOBS=2 BUNDLE_PATH=/bundle
RUN bundle install --without test development

ENV APP /app
RUN mkdir $APP
WORKDIR $APP
ADD . $APP

# fix for teleport
RUN ln -s /usr/local/bundle/bin/bundle /usr/local/bin/bundle
EXPOSE 3000
