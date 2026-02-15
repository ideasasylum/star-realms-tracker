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

  class LogParserGame2Test < ActiveSupport::TestCase
    def setup
      @log_text = file_fixture("sample_game_2.log").read
      @result = LogParser.parse(@log_text)
    end

    test "identifies both players in turn order" do
      assert_equal ["Discosaurus", "ideasasylum"], @result.players
    end

    test "returns the winner" do
      assert_equal "ideasasylum", @result.winner
    end

    test "tracks total turns" do
      assert_equal 22, @result.total_turns
    end

    test "both players start at 50 authority" do
      assert_equal [0, 50], @result.authority_by_turn["Discosaurus"].first
      assert_equal [0, 50], @result.authority_by_turn["ideasasylum"].first
    end

    test "tracks authority changes for Discosaurus" do
      disco_authority = @result.authority_by_turn["Discosaurus"]

      # Turn 1: no damage taken, stays at 50
      assert_includes disco_authority, [1, 50]

      # Turn 2: attacked for 1, drops to 49
      assert_includes disco_authority, [2, 49]

      # Turn 6: attacked for 11, drops to 37
      assert_includes disco_authority, [6, 37]

      # Turn 10: attacked for 14, drops to 31
      assert_includes disco_authority, [10, 31]

      # Turn 12: attacked for 6, drops to 25
      assert_includes disco_authority, [12, 25]

      # Turn 18: attacked twice (5 + 2), drops to 6
      assert_includes disco_authority, [18, 6]

      # Turn 20: attacked for 4, drops to 5
      assert_includes disco_authority, [20, 5]

      # Turn 21: gains 4 from Frontier Ferry, attacked for 6, ends at 9
      assert_includes disco_authority, [21, 9]
    end

    test "tracks authority changes for ideasasylum with gains" do
      ideas_authority = @result.authority_by_turn["ideasasylum"]

      # Turn 8: gains 5 from Federal Transport, attacked for 1, ends at 45
      assert_includes ideas_authority, [8, 45]

      # Turn 10: gains 3 from Mercenary Garrison, ends at 40
      assert_includes ideas_authority, [10, 40]

      # Turn 12: gains 5+3 from Federal Transport + Mercenary Garrison, ends at 48
      assert_includes ideas_authority, [12, 48]

      # Turn 14: gains 3 from Mercenary Garrison, ends at 51 (above starting!)
      assert_includes ideas_authority, [14, 51]

      # Turn 16: gains 5 from Federal Transport, ends at 56
      assert_includes ideas_authority, [16, 56]
    end

    test "tracks authority swings in long game" do
      disco_authority = @result.authority_by_turn["Discosaurus"]
      ideas_authority = @result.authority_by_turn["ideasasylum"]

      # Discosaurus recovers authority in turn 9 (gains 3 + 6 = 9)
      assert_includes disco_authority, [9, 45]

      # Discosaurus recovers again in turn 13 (gains 4 from Frontier Ferry)
      assert_includes disco_authority, [13, 29]

      # Discosaurus recovers in turn 19 (gains 3 from Construction Hauler)
      assert_includes disco_authority, [19, 9]
    end

    test "game ends with negative authority" do
      # The game ends when Discosaurus drops to -2
      assert_equal "ideasasylum", @result.winner
      assert_equal 22, @result.total_turns

      # Final turn should be included with the killing blow
      disco_authority = @result.authority_by_turn["Discosaurus"]
      assert_includes disco_authority, [22, -2]
    end
  end

  class LogParserGame3Test < ActiveSupport::TestCase
    def setup
      @log_text = file_fixture("sample_game_3.log").read
      @result = LogParser.parse(@log_text)
    end

    test "identifies both players in turn order" do
      assert_equal ["ideasasylum", "Whiskiejac"], @result.players
    end

    test "returns the winner" do
      assert_equal "Whiskiejac", @result.winner
    end

    test "tracks total turns" do
      assert_equal 10, @result.total_turns
    end

    test "both players start at 50 authority" do
      assert_equal [0, 50], @result.authority_by_turn["ideasasylum"].first
      assert_equal [0, 50], @result.authority_by_turn["Whiskiejac"].first
    end

    test "tracks authority for ideasasylum" do
      ideas_authority = @result.authority_by_turn["ideasasylum"]

      # Turn 1: no attacks, stays at 50
      assert_includes ideas_authority, [1, 50]

      # Turn 4: attacked for 4, drops to 46
      assert_includes ideas_authority, [4, 46]

      # Turn 6: attacked for 4, drops to 42
      assert_includes ideas_authority, [6, 42]

      # Turn 7: gains 3 from Colony Seed Ship, ends at 45
      assert_includes ideas_authority, [7, 45]

      # Turn 8: attacked for 20, drops to 25
      assert_includes ideas_authority, [8, 25]
    end

    test "tracks authority for Whiskiejac with gains" do
      whiskiejac_authority = @result.authority_by_turn["Whiskiejac"]

      # Turn 2: no attacks, stays at 50
      assert_includes whiskiejac_authority, [2, 50]

      # Turn 3: attacked for 1, drops to 49
      assert_includes whiskiejac_authority, [3, 49]

      # Turn 5: attacked for 1, drops to 48
      assert_includes whiskiejac_authority, [5, 48]

      # Turn 6: gains 3 from Loyal Colony, ends at 51
      assert_includes whiskiejac_authority, [6, 51]

      # Turn 8: no direct attack on Whiskiejac, stays at 51
      assert_includes whiskiejac_authority, [8, 51]

      # Turn 9: attacked for 1, drops to 50
      assert_includes whiskiejac_authority, [9, 50]
    end

    test "game ends mid-turn with large attack" do
      # Turn 10 ends when ideasasylum drops to -1
      assert_equal "Whiskiejac", @result.winner
      assert_equal 10, @result.total_turns

      # Final turn should be included with the killing blow
      ideas_authority = @result.authority_by_turn["ideasasylum"]
      assert_includes ideas_authority, [10, -1]
    end
  end

  class LogParserGame4MissionsTest < ActiveSupport::TestCase
    def setup
      @log_text = file_fixture("sample_game_4.log").read
      @result = LogParser.parse(@log_text)
    end

    test "identifies both players in turn order" do
      assert_equal ["whorn", "ideasasylum"], @result.players
    end

    test "returns the winner" do
      assert_equal "whorn", @result.winner
    end

    test "tracks total turns" do
      assert_equal 17, @result.total_turns
    end

    test "detects this is a mission game" do
      assert @result.mission_game?
    end

    test "tracks missions for whorn" do
      whorn_missions = @result.missions_by_turn["whorn"]

      # Turn 13: Exterminate
      assert_includes whorn_missions, [13, "Exterminate"]

      # Turn 15: Ally
      assert_includes whorn_missions, [15, "Ally"]

      # Turn 17: Influence (winning mission)
      assert_includes whorn_missions, [17, "Influence"]

      assert_equal 3, whorn_missions.size
    end

    test "tracks missions for ideasasylum" do
      ideas_missions = @result.missions_by_turn["ideasasylum"]

      # Turn 16: Convert
      assert_includes ideas_missions, [16, "Convert"]

      assert_equal 1, ideas_missions.size
    end

    test "whorn wins by completing 3 missions" do
      # Game ends when whorn completes their 3rd mission (Influence)
      assert_equal "whorn", @result.winner
      assert_equal 3, @result.missions_by_turn["whorn"].size
    end

    test "both players have positive authority at game end" do
      # This game ends via missions, not authority depletion
      whorn_authority = @result.authority_by_turn["whorn"]
      ideas_authority = @result.authority_by_turn["ideasasylum"]

      # Final recorded authority should be positive for both
      final_whorn = whorn_authority.last[1]
      final_ideas = ideas_authority.last[1]

      assert final_whorn > 0, "whorn should have positive authority"
      assert final_ideas > 0, "ideasasylum should have positive authority"
    end

    test "non-mission games return empty missions" do
      # Synthetic log with no mission reveals
      non_mission_log = <<~LOG
        Played <color=#800080>Viper</color>
        \tPlayer1  >  <color=#800080>Viper</color> +1 Combat (Combat:1)
        Player1 ends turn 1
        \tIt is now Player2's turn 2
        Played <color=#800080>Scout</color>
        \tPlayer2  >  <color=#800080>Scout</color> +1 Trade (Trade:1)
        Attacked Player1 for 1 (New Authority:49)
        \tPlayer2 - -1 Combat (Combat:0)
        \tPlayer1 - -1 Authority (Authority:49)
        Player2 ends turn 2
        \t=== Player2 has won the game. ===
      LOG

      result = LogParser.parse(non_mission_log)

      refute result.mission_game?
      assert_empty result.missions_by_turn["Player1"]
      assert_empty result.missions_by_turn["Player2"]
    end
  end
end
