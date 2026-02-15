# frozen_string_literal: true

class Game < ApplicationRecord
  validates :log_text, presence: true
  validates :player_1_name, presence: true
  validates :player_2_name, presence: true
  validates :total_turns, presence: true, numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }

  def players
    [player_1_name, player_2_name]
  end

  # Returns players with winner first
  def players_by_result
    if winner_name == player_2_name
      [player_2_name, player_1_name]
    else
      [player_1_name, player_2_name]
    end
  end

  def final_score
    "#{player_1_final_authority} : #{player_2_final_authority}"
  end

  # Returns score with winner's score first
  def final_score_by_result
    if winner_name == player_2_name
      "#{player_2_final_authority} : #{player_1_final_authority}"
    else
      "#{player_1_final_authority} : #{player_2_final_authority}"
    end
  end

  def complete?
    winner_name.present?
  end

  def parsed_result
    @parsed_result ||= StarRealms::LogParser.parse(log_text)
  end

  def self.create_from_log(log_text)
    result = StarRealms::LogParser.parse(log_text)
    return nil if result.players.empty?

    # Get final authority for each player
    player_1_authority = result.authority_by_turn[result.players[0]]&.last&.last
    player_2_authority = result.authority_by_turn[result.players[1]]&.last&.last

    create(
      log_text: log_text,
      player_1_name: result.players[0],
      player_2_name: result.players[1],
      winner_name: result.winner,
      player_1_final_authority: player_1_authority,
      player_2_final_authority: player_2_authority,
      total_turns: result.total_turns,
      is_mission_game: result.mission_game?
    )
  end
end
