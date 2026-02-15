# frozen_string_literal: true

module StarRealms
  # Parses Star Realms game logs and extracts game state
  #
  # Example usage:
  #   log_text = File.read("game.log")
  #   result = StarRealms::LogParser.parse(log_text)
  #   result.players           # => ["Heofty", "ideasasylum"]
  #   result.authority_by_turn # => {"Heofty" => [[0, 50], [1, 50], ...], ...}
  #   result.winner            # => "ideasasylum"
  #   result.total_turns       # => 16
  #
  class LogParser
    STARTING_AUTHORITY = 50

    # Regex patterns for parsing
    TURN_START = /It is now (?<player>.+)'s turn (?<turn>\d+)/
    TURN_END = /^(?<player>.+) ends turn (?<turn>\d+)$/
    AUTHORITY_LOSS = /(?<player>\S+) - -(?<amount>\d+) Authority \(Authority:(?<new_value>\d+)\)/
    AUTHORITY_GAIN = /(?<player>\S+) - \+(?<amount>\d+) Authority \(Authority:(?<new_value>\d+)\)/
    WINNER = /=== (?<player>.+) has won the game/

    def self.parse(log_text)
      new(log_text).parse
    end

    def initialize(log_text)
      @log_text = log_text
      @lines = log_text.lines.map(&:chomp)
      @players = []
      @authority = {}
      @authority_by_turn = {}
      @winner = nil
      @current_turn = 0
      @max_turn = 0
    end

    def parse
      identify_players
      initialize_authority
      parse_events

      GameResult.new(
        players: @players,
        authority_by_turn: @authority_by_turn,
        winner: @winner,
        total_turns: @max_turn
      )
    end

    private

    def identify_players
      @lines.each do |line|
        # First player is identified from "ends turn 1" (they go first)
        if (match = line.match(TURN_END))
          player = match[:player]
          @players << player unless @players.include?(player)
        end

        # Second player is identified from "It is now X's turn 2"
        if (match = line.match(TURN_START))
          player = match[:player]
          @players << player unless @players.include?(player)
        end

        break if @players.size == 2
      end
    end

    def initialize_authority
      @players.each do |player|
        @authority[player] = STARTING_AUTHORITY
        @authority_by_turn[player] = [[0, STARTING_AUTHORITY]]
      end
    end

    def parse_events
      @lines.each do |line|
        parse_line(line)
      end
    end

    def parse_line(line)
      stripped = line.strip

      # Check for winner
      if (match = stripped.match(WINNER))
        @winner = match[:player]
        return
      end

      # Check for authority changes (can happen on effect lines)
      if (match = stripped.match(AUTHORITY_LOSS))
        update_authority(match[:player], match[:new_value].to_i)
        return
      end

      if (match = stripped.match(AUTHORITY_GAIN))
        update_authority(match[:player], match[:new_value].to_i)
        return
      end

      # Track turn starts to capture games that end mid-turn
      if (match = stripped.match(TURN_START))
        turn = match[:turn].to_i
        @max_turn = turn if turn > @max_turn
        return
      end

      # Check for turn end (snapshot authority at end of turn)
      if (match = line.match(TURN_END))
        @current_turn = match[:turn].to_i
        @max_turn = @current_turn if @current_turn > @max_turn
        snapshot_authority
      end
    end

    def update_authority(player, new_value)
      return unless @authority.key?(player)

      @authority[player] = new_value
    end

    def snapshot_authority
      @players.each do |player|
        @authority_by_turn[player] << [@current_turn, @authority[player]]
      end
    end
  end
end
