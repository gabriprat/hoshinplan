FROM ruby:2.5.7
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apt-get update
RUN apt-get install -y nodejs

RUN bundle install
RUN bundle exec passenger --version
COPY . .
RUN ./assets.sh
EXPOSE 3000

ENTRYPOINT ["./run.sh"]

# Configure the main process to run when running the image
CMD ["/start", "web"]