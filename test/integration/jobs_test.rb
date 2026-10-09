# frozen_string_literal: true

require "test_helper"

class JobsTest < ActionDispatch::IntegrationTest
  test "new renders the jobs page" do
    get new_job_path

    assert_response :success
    assert_includes response.body, "Enqueue job(s)"
    assert_includes response.body, "Queues"
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", new_job_path
  end

  test "new.json returns queue stats" do
    get new_job_path(format: :json)

    assert_response :success
    assert_equal "application/json", response.media_type

    body = JSON.parse(response.body)
    assert_kind_of Array, body
  end

  test "create enqueues jobs and redirects with params" do
    assert_difference -> { Job.jobs.size }, 5 do
      post jobs_path, params: {
        job_manager: { jobs: 5, latency: 1000, queue: "default" }
      }
    end

    assert_redirected_to new_job_path(
      job_manager: { jobs: "5", latency: "1000", queue: "default" }
    )

    follow_redirect!
    assert_response :success
    assert_includes response.body, "Enqueue job(s)"
  end

  test "create can target the urgent queue" do
    post jobs_path, params: {
      job_manager: { jobs: 2, latency: 5000, queue: "urgent" }
    }

    assert_equal 2, Job.jobs.size
    assert Job.jobs.all? { |job| job["queue"] == "urgent" }
  end

  test "sidekiq web is mounted" do
    get "/sidekiq"

    assert_includes [200, 302], response.status
  end
end
