# frozen_string_literal: true

require "test_helper"

class JobManagerTest < ActiveSupport::TestCase
  test "defaults" do
    manager = JobManager.new

    assert_equal 1000, manager.latency
    assert_equal 10, manager.jobs
    assert_equal "default", manager.queue
  end

  test "enqueue! pushes the requested number of jobs onto the queue" do
    manager = JobManager.new(latency: 2500, jobs: 3, queue: "urgent")

    assert_difference -> { Job.jobs.size }, 3 do
      manager.enqueue!
    end

    jobs = Job.jobs
    assert jobs.all? { |job| job["queue"] == "urgent" }
    assert jobs.all? { |job| job["args"] == [2500] }
  end
end
