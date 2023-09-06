# Make sure it matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libvips libpq-dev gnupg2 curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]

#### BUILD AND DEPLOY COMMAND SEQUENCE
#$>
#$> docker build --platform=linux/arm64 -t autoscale-example-ruby-app .
#$>
#$> docker tag autoscale-example-ruby-app:latest 171135638599.dkr.ecr.us-east-2.amazonaws.com/autoscale-example-ruby-app:latest
#$>
#$> aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 171135638599.dkr.ecr.us-east-2.amazonaws.com
#$>
#$> docker push 171135638599.dkr.ecr.us-east-2.amazonaws.com/autoscale-example-ruby-app:latest
