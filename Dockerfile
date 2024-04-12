FROM ruby:3.2.3

RUN apt-get update -qq && apt-get install -y nodejs
WORKDIR /auth_app
COPY Gemfile /auth_app_experiment/Gemfile
COPY Gemfile.lock /auth_app_experiment/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3007

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3007"]
