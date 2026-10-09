# frozen_string_literal: true

require "test_helper"
require "capybara/cuprite"

Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by re-registers the driver; options must be passed here (a prior
  # Capybara.register_driver(:cuprite) block is overwritten and ignored).
  driven_by :cuprite, screen_size: [1400, 1400], options: {
    process_timeout: 60,
    timeout: 15,
    headless: !ENV["HEADLESS"].in?(%w[0 false]),
    browser_options: {
      "no-sandbox": nil,
      "disable-gpu": nil,
      "disable-dev-shm-usage": nil
    }
  }.tap { |opts|
    opts[:browser_path] = ENV["BROWSER_PATH"] if ENV["BROWSER_PATH"].present?
  }

  setup do
    # Queue stats and enqueue hit real Redis (Sidekiq::Queue / push_bulk).
    Sidekiq::Testing.disable!
    flush_sidekiq_redis!
  end

  teardown do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end
end
