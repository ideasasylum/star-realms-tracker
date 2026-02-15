# Star Realms Tracker

A Ruby on Rails application for analysing and visualizing Star Realms game logs. Paste your game log to see authority progression over turns as an interactive chart, with full game history storage.

## Features

- **Log Analysis**: Extracts player names, turn counts, authority changes, and winner from Star Realms game logs
- **Authority Tracking**: Tracks both authority losses (from attacks) and gains (from cards like Federal Transport, Mercenary Garrison)
- **Mission Support**: Detects mission game mode and tracks mission completions with star markers on the chart
- **Game Persistence**: Stores complete game logs and parsed stats in a database for historical tracking
- **Re-parsing**: Stored logs can be re-parsed as the parser improves
- **Interactive Charts**: Visualizes authority progression using Chart.js with neon-styled dark theme
- **Space Theme**: Futuristic UI with animated starfield background, neon accents, and transparent buttons
- **Mobile Responsive**: Fully responsive design for phones and tablets

## Requirements

- Ruby 3.4.2
- Rails 8.1
- SQLite3

## Setup

```bash
# Clone the repository
git clone <repository-url>
cd star-realms-tracker

# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the server
bin/rails server
```

Visit `http://localhost:3000` to use the application.

## Usage

1. Click "Analyse New Game" from the home page
2. Copy your game log from Star Realms (the complete log output)
3. Paste it into the text area
4. Click "Analyse & Save Game" to see:
   - Players (in turn order)
   - Total turns played
   - Winner (if game completed)
   - Mission completions (for mission mode games)
   - Authority chart showing both players' authority over time
5. The game is automatically saved and appears in your game history

## How to Get Game Logs

In the Star Realms app:
1. During or after a game, access the game log
2. Copy the entire log text
3. Paste into the tracker

## Architecture

```
app/
├── controllers/
│   └── games_controller.rb       # index, show, new, create actions
├── models/
│   └── game.rb                   # Game persistence and re-parsing
├── services/
│   └── star_realms/
│       ├── log_parser.rb         # Main parser with regex patterns
│       └── game_result.rb        # Data object for parsed results
└── views/
    └── games/
        ├── index.html.erb        # Game history list
        ├── show.html.erb         # Individual game with chart
        └── new.html.erb          # Log input form
```

### Database Schema

```
games
├── log_text                 # Complete raw log for re-parsing
├── player_1_name
├── player_2_name
├── winner_name
├── player_1_final_authority
├── player_2_final_authority
├── total_turns
├── is_mission_game
└── timestamps
```

### Log Parser

The parser uses regex patterns to extract:

| Pattern | Purpose |
|---------|---------|
| `It is now {player}'s turn {N}` | Turn start detection |
| `{player} ends turn {N}` | Turn end (triggers authority snapshot) |
| `{player} - -{N} Authority (Authority:{M})` | Direct authority loss |
| `{player} - +{N} Authority (Authority:{M})` | Direct authority gain |
| `{player} > <card> +N Authority (Authority:{M})` | Card-based authority gain |
| `Revealed {MissionName}` | Mission completion |
| `=== {player} has won the game` | Winner detection |

### Supported Missions

Exterminate, Ally, Convert, Influence, Dominate, Rule, Unite, Colonize, Defend, Diversify, Armada

### GameResult Object

```ruby
result = StarRealms::LogParser.parse(log_text)

result.players           # => ["Player1", "Player2"]
result.authority_by_turn # => {"Player1" => [[0, 50], [1, 50], ...]}
result.winner            # => "Player2" or nil
result.total_turns       # => 16
result.missions_by_turn  # => {"Player1" => [[5, "Ally"]], "Player2" => []}
result.mission_game?     # => true/false
```

## Running Tests

```bash
# Run all tests
bin/rails test

# Run parser tests only
bin/rails test test/services/star_realms/log_parser_test.rb

# Run controller tests
bin/rails test test/controllers/games_controller_test.rb
```

## Development

### Adding Support for New Log Formats

1. Add a sample log to `test/fixtures/files/`
2. Write tests for expected behavior in `log_parser_test.rb`
3. Add regex patterns to `LogParser` as needed
4. Run tests to verify

### Re-parsing Stored Games

Games store the complete raw log, so you can re-parse them when the parser improves:

```ruby
game = Game.find(id)
result = game.parsed_result  # Re-parses the stored log
```

### Code Style

```bash
# Run RuboCop
bin/rubocop
```

## Known Limitations

- Only supports 2-player games
- Does not track card acquisitions or deck composition (future feature)
- Some edge cases in log formats may not be handled

## License

MIT
