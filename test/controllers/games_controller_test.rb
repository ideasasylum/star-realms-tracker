# frozen_string_literal: true

require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get root_path
    assert_response :success
    assert_select "h1", "Star Realms Log Parser"
    assert_select "textarea[name=log_text]"
  end

  test "should parse log and show results" do
    log_text = file_fixture("sample_game.log").read

    post games_path, params: { log_text: log_text }

    assert_response :success
    assert_select ".results h2", "Game Results"
    assert_select ".summary", /Heofty vs ideasasylum/
    assert_select ".summary", /Winner:.*ideasasylum/
    assert_select "canvas#authorityChart"
  end

  test "should show error for empty log" do
    post games_path, params: { log_text: "" }

    assert_response :success
    assert_select ".results", false
    assert_select ".error", false
  end

  test "should show error for invalid log" do
    post games_path, params: { log_text: "this is not a valid log" }

    assert_response :success
    assert_select ".error", /Could not parse game log/
  end
end
