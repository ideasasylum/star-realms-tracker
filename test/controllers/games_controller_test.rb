# frozen_string_literal: true

require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_path
    assert_response :success
    assert_select "h1", "Star Realms Tracker"
  end

  test "should get new" do
    get new_game_path
    assert_response :success
    assert_select "h1", "Analyse New Game"
    assert_select "textarea[name=log_text]"
  end

  test "should create game and redirect to show" do
    log_text = file_fixture("sample_game.log").read

    assert_difference("Game.count", 1) do
      post games_path, params: { log_text: log_text }
    end

    game = Game.last
    assert_redirected_to game_path(game)

    # Follow redirect and check show page
    follow_redirect!
    assert_response :success
    assert_select ".summary", /Heofty vs ideasasylum/
    assert_select ".summary .winner", /ideasasylum/
    assert_select "canvas#authorityChart"
  end

  test "should show game" do
    log_text = file_fixture("sample_game.log").read
    game = Game.create_from_log(log_text)

    get game_path(game)

    assert_response :success
    assert_select "h1", "Game Details"
    assert_select ".summary", /Heofty vs ideasasylum/
    assert_select "canvas#authorityChart"
  end

  test "should render new for empty log" do
    assert_no_difference("Game.count") do
      post games_path, params: { log_text: "" }
    end

    assert_response :success
    assert_select ".error", false
  end

  test "should show error for invalid log" do
    assert_no_difference("Game.count") do
      post games_path, params: { log_text: "this is not a valid log" }
    end

    assert_response :success
    assert_select ".error", /Could not analyse game log/
  end

  test "index shows list of games" do
    log_text = file_fixture("sample_game.log").read
    game = Game.create_from_log(log_text)

    get games_path

    assert_response :success
    assert_select ".games-table tbody tr", minimum: 1
    assert_select ".games-table", /Heofty/
    assert_select ".games-table", /ideasasylum/
  end
end
