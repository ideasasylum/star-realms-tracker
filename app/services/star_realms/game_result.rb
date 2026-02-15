# frozen_string_literal: true

module StarRealms
  # Simple data object for parsed game results
  class GameResult
    FACTIONS = %i[neutral blob machine_cult star_empire trade_federation].freeze

    attr_reader :players, :authority_by_turn, :winner, :total_turns, :missions_by_turn, :deck_by_turn

    def initialize(players:, authority_by_turn:, winner:, total_turns:, missions_by_turn: {}, deck_by_turn: {})
      @players = players
      @authority_by_turn = authority_by_turn
      @winner = winner
      @total_turns = total_turns
      @missions_by_turn = missions_by_turn
      @deck_by_turn = deck_by_turn
    end

    def mission_game?
      @missions_by_turn.values.any?(&:any?)
    end

    def final_deck(player)
      return nil unless @deck_by_turn.key?(player)

      turns = @deck_by_turn[player]
      return nil if turns.empty?

      turns.last[1]
    end

    def final_deck_size(player)
      deck = final_deck(player)
      return 0 unless deck

      deck.values.sum
    end

    # Returns deck size progression: {player => [[turn, size], ...]}
    def deck_size_by_turn
      @deck_by_turn.transform_values do |turns|
        turns.map { |turn, deck| [turn, deck.values.sum] }
      end
    end
  end
end
