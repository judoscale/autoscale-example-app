require 'uri'

if defined?(JudoScale)
  JudoScale.configure do |config|
    if (host = ENV["JUDOSCALE_HOST"])
      # Send reports to a custom host for testing
      original_url = ENV["JUDOSCALE_URL"] || "https://adapter.judoscale.com/api"
      original_url += "#{ENV["RENDER_SERVICE_ID"]}" if ENV["RENDER_SERVICE_ID"]

      uri = URI.parse(original_url)
      uri.host = host

      config.api_base_url = uri.to_s
    end
  end
end
