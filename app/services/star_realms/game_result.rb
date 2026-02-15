# frozen_string_literal: true

module StarRealms
  # Simple data object for parsed game results
  class GameResult
    attr_reader :players, :authority_by_turn, :winner, :total_turns

    def initialize(players:, authority_by_turn:, winner:, total_turns:)
      @players = players
      @authority_by_turn = authority_by_turn
      @winner = winner
      @total_turns = total_turns
    end
  end
end
