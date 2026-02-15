# frozen_string_literal: true

module StarRealms
  # Simple data object for parsed game results
  class GameResult
    attr_reader :players, :authority_by_turn, :winner, :total_turns, :missions_by_turn

    def initialize(players:, authority_by_turn:, winner:, total_turns:, missions_by_turn: {})
      @players = players
      @authority_by_turn = authority_by_turn
      @winner = winner
      @total_turns = total_turns
      @missions_by_turn = missions_by_turn
    end

    def mission_game?
      @missions_by_turn.values.any?(&:any?)
    end
  end
end
