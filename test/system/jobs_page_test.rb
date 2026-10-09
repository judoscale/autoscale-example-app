# frozen_string_literal: true

require "application_system_test_case"

class JobsPageTest < ApplicationSystemTestCase
  test "auto-refresh can be toggled" do
    visit new_job_path

    assert_link "on"
    click_link "on"
    assert_link "off"

    click_link "off"
    assert_link "on"
  end

  test "enqueueing jobs updates the queues table" do
    visit new_job_path

    choose "1 job"
    choose "1 sec"
    choose "default"
    click_button "Enqueue job(s)"

    assert_text "default", wait: 5
    assert_selector "td", text: "default"
    # Pending and/or busy should reflect the enqueued job until a worker drains it.
    assert_text(/\d+/, wait: 5)
  end
end
