source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.0"
gem "propshaft"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "tailwindcss-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "sidekiq", "~> 6.0"
gem "judoscale-ruby", git: "https://github.com/judoscale/judoscale-ruby", branch: "main", glob: "judoscale-ruby/*.gemspec"
gem "judoscale-rails", git: "https://github.com/judoscale/judoscale-ruby", branch: "main", glob: "judoscale-rails/*.gemspec"
gem "judoscale-sidekiq", git: "https://github.com/judoscale/judoscale-ruby", branch: "main", glob: "judoscale-sidekiq/*.gemspec"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console"
end
