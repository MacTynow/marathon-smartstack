FROM alpine

RUN apk --update add ruby ruby-dev build-base

RUN gem install bundler

WORKDIR /root
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
COPY . /root

CMD [ "./client.rb" ]