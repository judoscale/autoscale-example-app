source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", "~> 7.0.0"
gem "propshaft"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "tailwindcss-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "sidekiq", "~> 6.0"
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
