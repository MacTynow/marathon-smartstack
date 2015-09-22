FROM alpine

RUN apk --update add ruby ruby-dev build-base

RUN gem install bundler

WORKDIR /root
COPY . /root
RUN bundle install

CMD [ "ruby", "client.rb" ]