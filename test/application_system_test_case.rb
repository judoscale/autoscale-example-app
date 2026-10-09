# frozen_string_literal: true

require "test_helper"
require "capybara/cuprite"

Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 1400],
    process_timeout: 30,
    timeout: 15,
    headless: !ENV["HEADLESS"].in?(%w[0 false]),
    browser_options: {
      "no-sandbox": nil,
      "disable-gpu": nil,
      "disable-dev-shm-usage": nil
    }
  )
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite

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
