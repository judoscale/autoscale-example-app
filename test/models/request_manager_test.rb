# frozen_string_literal: true

require "test_helper"

class RequestManagerTest < ActiveSupport::TestCase
  test "defaults" do
    manager = RequestManager.new

    assert_equal 1000, manager.latency
    assert_equal 1, manager.rps
    assert_equal 100, manager.sleep_percent
  end

  test "hold! waits approximately latency milliseconds when fully sleeping" do
    manager = RequestManager.new(latency: 50, sleep_percent: 100)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    manager.hold!(started: started)

    elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000
    assert_in_delta 50, elapsed_ms, 40
  end

  test "hold! yields to the given block" do
    manager = RequestManager.new(latency: 20, sleep_percent: 100)
    yielded = false

    manager.hold! { yielded = true }

    assert yielded
  end

  test "hold! with zero sleep burns CPU until the deadline" do
    manager = RequestManager.new(latency: 40, sleep_percent: 0)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    manager.hold!(started: started)

    elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000
    assert_in_delta 40, elapsed_ms, 40
  end
end
