source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Only the Rails frameworks loaded in config/application.rb, instead of the
# "rails" meta-gem, which would also install Active Storage, Active Record, etc.
gem "railties", "~> 7.0.0"
gem "actionpack", "~> 7.0.0"
gem "actionview", "~> 7.0.0"
gem "activemodel", "~> 7.0.0"
gem "activesupport", "~> 7.0.0"
gem "propshaft"
gem "puma", "~> 7.2"
gem "importmap-rails"
gem "tailwindcss-rails", "~> 3.3", ">= 3.3.1"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "sidekiq", "~> 7.3"
gem "ostruct"
gem "logger"
gem "base64"
gem "bigdecimal"
gem "fiddle"
gem "mutex_m"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :test do
  # Rails 7.0's test runner is not compatible with minitest 6 yet.
  gem "minitest", "~> 5.25"
  gem "capybara"
  gem "cuprite"
end

group :development do
  gem "web-console"
end

gem "judoscale-rails", "~> 1.13.0"
gem "judoscale-sidekiq", "~> 1.13.0"
