FROM ruby:2.7.4
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL

# Install specific bundler version before setting frozen config
RUN gem install bundler -v 1.17.3
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apt-get update
RUN apt-get install -y nodejs libpcre2-dev nginx

RUN bundle _1.17.3_ install --deployment
RUN bundle exec passenger --version
COPY . .
EXPOSE 3000

ENTRYPOINT ["./run.sh"]

# Configure the main process to run when running the image
CMD ["/start", "web"]