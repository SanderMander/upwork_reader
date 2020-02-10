FROM ruby:2.6.4

RUN apt-get update -qq
RUN apt-get install -y libxml2-dev libxslt-dev build-essential libpq-dev

COPY . .

RUN gem install bundler
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
RUN chmod +x parse.rb

CMD ["bundle","exec", "parse.rb"]
