# frozen_string_literal: true

require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "root renders the requests page" do
    get root_path

    assert_response :success
    assert_includes response.body, "Start sending requests"
    assert_includes response.body, "Requests"
    assert_includes response.body, "Jobs"
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", new_job_path
  end

  test "load-test query params return an empty body" do
    get root_path, params: { latency: 100, sleep_percent: 100 }

    assert_response :success
    assert_equal "", response.body
  end

  test "nested request_manager params also trigger load-test mode" do
    get root_path, params: { request_manager: { latency: 100, sleep_percent: 50, rps: 1 } }

    assert_response :success
    assert_equal "", response.body
  end

  test "echoes X-Request-Start when the client sends it" do
    get root_path, headers: { "X-Request-Start" => "t=1710000000.123" }

    assert_response :success
    assert_equal "t=1710000000.123", response.headers["X-Request-Start"]
  end

  test "exposes X-Queue-Time when Judoscale reports queue time" do
    # Judoscale middleware derives queue time from X-Request-Start.
    started = format("t=%.3f", Process.clock_gettime(Process::CLOCK_REALTIME) - 0.05)
    get root_path, headers: { "X-Request-Start" => started }

    assert_response :success
    queue_time = response.headers["X-Queue-Time"]
    assert_not_nil queue_time, "expected Judoscale to populate X-Queue-Time"
    assert_operator Integer(queue_time), :>=, 0
  end
end
