# syntax=docker/dockerfile:1
# check=error=true

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.12
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# jemalloc reduces memory usage and latency
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libjemalloc2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so

ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so" \
    RAILS_ENV="production" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="1"


FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libffi-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .
RUN bundle exec bootsnap precompile --gemfile app/ lib/ && \
    SECRET_KEY_BASE=DUMMY ./bin/rails assets:precompile


FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run as a non-root user that owns only the runtime files
RUN useradd rails --uid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails log tmp
USER rails

EXPOSE 3000
CMD ["./bin/rails", "server"]
