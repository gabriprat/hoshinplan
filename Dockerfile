FROM ruby:2.5.7
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apt-get update
RUN apt-get install -y nodejs

RUN bundle install --deployment
RUN bundle exec passenger --version
COPY . .
EXPOSE 3000

ENTRYPOINT ["./run.sh"]

# Configure the main process to run when running the image
CMD ["/start", "web"]