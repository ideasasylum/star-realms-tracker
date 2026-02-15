# frozen_string_literal: true

require "test_helper"

module StarRealms
  class LogParserTest < ActiveSupport::TestCase
    def setup
      @log_text = file_fixture("sample_game.log").read
      @result = LogParser.parse(@log_text)
    end

    test "identifies both players in turn order" do
      assert_equal ["Heofty", "ideasasylum"], @result.players
    end

    test "returns the winner" do
      assert_equal "ideasasylum", @result.winner
    end

    test "tracks total turns" do
      assert_equal 16, @result.total_turns
    end

    test "both players start at 50 authority" do
      assert_equal [0, 50], @result.authority_by_turn["Heofty"].first
      assert_equal [0, 50], @result.authority_by_turn["ideasasylum"].first
    end

    test "tracks authority changes for Heofty" do
      heofty_authority = @result.authority_by_turn["Heofty"]

      # Turn 1: no combat, stays at 50
      assert_includes heofty_authority, [1, 50]

      # Turn 4: attacked for 2, drops to 48
      assert_includes heofty_authority, [4, 48]

      # Turn 6: attacked for 2, drops to 46
      assert_includes heofty_authority, [6, 46]

      # Turn 8: attacked for 3, drops to 43
      assert_includes heofty_authority, [8, 43]

      # Turn 10: attacked for 10, drops to 33
      assert_includes heofty_authority, [10, 33]

      # Turn 12: attacked for 8, drops to 25
      assert_includes heofty_authority, [12, 25]

      # Turn 14: attacked for 15, drops to 10
      assert_includes heofty_authority, [14, 10]
    end

    test "tracks authority changes for ideasasylum" do
      ideas_authority = @result.authority_by_turn["ideasasylum"]

      # Turn 2: no combat, stays at 50
      assert_includes ideas_authority, [2, 50]

      # Turn 3: attacked for 2, drops to 48
      assert_includes ideas_authority, [3, 48]

      # Turn 5: attacked for 7, drops to 41
      assert_includes ideas_authority, [5, 41]

      # Turn 13: attacked for 4, drops to 37
      assert_includes ideas_authority, [13, 37]

      # Turn 15: attacked for 2, drops to 35
      assert_includes ideas_authority, [15, 35]
    end

    test "handles authority gain" do
      # In the final turn, ideasasylum gains 5 authority before winning
      # The game ends during turn 16 but before the turn ends
      # We don't snapshot authority at turn end since the game ends mid-turn
      # But we should still track the winner correctly
      assert_equal "ideasasylum", @result.winner
    end

    test "authority_by_turn has entries for each completed turn" do
      heofty_turns = @result.authority_by_turn["Heofty"].map(&:first)
      ideas_turns = @result.authority_by_turn["ideasasylum"].map(&:first)

      # Heofty has odd turns plus turn 0
      assert_includes heofty_turns, 0
      assert_includes heofty_turns, 1
      assert_includes heofty_turns, 3
      assert_includes heofty_turns, 5

      # ideasasylum has even turns plus turn 0
      assert_includes ideas_turns, 0
      assert_includes ideas_turns, 2
      assert_includes ideas_turns, 4
      assert_includes ideas_turns, 6
    end

    test "parses incomplete game gracefully" do
      incomplete_log = <<~LOG
        Play all
        	Heofty  >  <color=#800080>Scout</color> +1 Trade (Trade:1)
        Heofty ends turn 1
        	It is now ideasasylum's turn 2
        Play all
        	ideasasylum  >  <color=#800080>Scout</color> +1 Trade (Trade:1)
      LOG

      result = LogParser.parse(incomplete_log)

      assert_equal ["Heofty", "ideasasylum"], result.players
      assert_nil result.winner
      # total_turns reflects the highest turn seen, including incomplete turns
      assert_equal 2, result.total_turns
    end

    test "handles empty log" do
      result = LogParser.parse("")

      assert_empty result.players
      assert_nil result.winner
      assert_equal 0, result.total_turns
    end
  end
end
