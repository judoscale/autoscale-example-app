source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.1"

gem "rails"
gem "propshaft"
gem "puma"
gem "importmap-rails"
gem "tailwindcss-rails", "~> 3.0"
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

group :development do
  gem "web-console"
end
