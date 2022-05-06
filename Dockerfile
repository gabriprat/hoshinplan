FROM ruby:2.5.7
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .
EXPOSE 3000

ENTRYPOINT ["./run.sh"]

# Configure the main process to run when running the image
CMD ["/start", "web"]