class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.text :log_text
      t.string :player_1_name
      t.string :player_2_name
      t.string :winner_name
      t.integer :player_1_final_authority
      t.integer :player_2_final_authority
      t.integer :total_turns
      t.boolean :is_mission_game

      t.timestamps
    end
  end
end
