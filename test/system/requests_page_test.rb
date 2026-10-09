# frozen_string_literal: true

require "application_system_test_case"

class RequestsPageTest < ApplicationSystemTestCase
  test "start and stop client-side request sending" do
    visit root_path

    assert_button "Start sending requests"
    choose "100 ms"

    click_button "Start sending requests"
    assert_button "Stop sending requests"

    assert_selector "td", text: /^[1-9]\d*$/, wait: 10
    assert_text(/ms/, wait: 10)

    click_button "Stop sending requests"
    assert_button "Start sending requests"
  end

  test "terminal snippets track the selected latency" do
    visit root_path

    assert_button "Start sending requests"
    choose "500 ms"

    assert_selector "code", text: /latency=500/
    assert_selector "code", text: /vegeta attack -rate=1/
  end
end
