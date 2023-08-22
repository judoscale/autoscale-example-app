require 'uri'

if defined?(Judoscale)
  Judoscale.configure do |config|
    # Send reports to a custom host for testing
    host = ENV["JUDOSCALE_HOST"]

    original_url = if (render_service_id = ENV["RENDER_SERVICE_ID"])
      "https://adapter.judoscale.com/api/#{render_service_id}"
    elsif (url_env_key = ENV.keys.grep(/JUDOSCALE.*_URL/).first)
      ENV[url_env_key]
    end

    if host && original_url
      uri = URI.parse(original_url)
      uri.host = host

      config.api_base_url = uri.to_s
    end
  end
end
