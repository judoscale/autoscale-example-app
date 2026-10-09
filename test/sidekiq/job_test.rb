# frozen_string_literal: true

require "test_helper"

class JobTest < ActiveSupport::TestCase
  test "perform sleeps for the given latency" do
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    Job.new.perform(40)

    elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000
    assert_in_delta 40, elapsed_ms, 40
  end
end
