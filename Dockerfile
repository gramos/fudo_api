FROM ruby:3.4.10-slim-bookworm

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "-s", "webrick", "-o", "0.0.0.0", "-p", "9292"]
