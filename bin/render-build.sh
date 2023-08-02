#!/usr/bin/env bash
# exit on error
set -xo errexit

bundle install
bundle exec rake assets:precompile assets:clean
