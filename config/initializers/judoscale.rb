require 'uri'

if defined?(Judoscale)
  Judoscale.configure do |config|
    # Send reports to a custom host for testing
    host = ENV["JUDOSCALE_HOST"]

    # Use with judoscale or judoscale-staging addons
    env_var_key = ENV.keys.grep(/JUDOSCALE.*_URL/).first

    original_url = if (render_service_id = ENV["RENDER_SERVICE_ID"])
      "https://adapter.judoscale.com/api/#{render_service_id}"
    elsif env_var_key
      ENV[env_var_key]
    end

    if original_url
      uri = URI.parse(original_url)
      uri.host = host if host

      config.api_base_url = uri.to_s
    end
  end
end
