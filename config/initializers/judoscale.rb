Judoscale.configure do |config|
  config.sidekiq.enabled = ENV["JUDOSCALE_SIDEKIQ_DISABLED"] != "true"
end
