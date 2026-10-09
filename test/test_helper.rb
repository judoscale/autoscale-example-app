# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["SECRET_KEY_BASE"] ||= "test-secret-key-base-for-autoscale-example-app"
ENV["REDIS_URL"] ||= "redis://127.0.0.1:6379/15"

require_relative "../config/environment"
require "rails/test_help"
require "sidekiq/testing"

module SidekiqRedisTestHelper
  def flush_sidekiq_redis!
    Sidekiq.redis(&:flushdb)
  end
end

class ActiveSupport::TestCase
  include SidekiqRedisTestHelper

  # Keep Redis DB 15 exclusive to this suite; avoid parallel workers sharing it.
  parallelize(workers: 1)

  setup do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end
end

class ActionDispatch::IntegrationTest
  include SidekiqRedisTestHelper
end
