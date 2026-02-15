# Star Realms Tracker

A Ruby on Rails application for parsing and visualizing Star Realms game logs. Paste your game log and see authority progression over turns as an interactive chart.

## Features

- **Log Parsing**: Extracts player names, turn counts, authority changes, and winner from Star Realms game logs
- **Authority Tracking**: Tracks both authority losses (from attacks) and gains (from cards like Federal Transport, Mercenary Garrison)
- **Interactive Charts**: Visualizes authority progression over turns using Chart.js
- **Robust Parsing**: Handles incomplete games, negative authority, and various log formats

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

1. Copy your game log from Star Realms (the complete log output)
2. Paste it into the text area on the home page
3. Click "Parse Game" to see:
   - Players (in turn order)
   - Total turns played
   - Winner (if game completed)
   - Authority chart showing both players' authority over time

## How to Get Game Logs

In the Star Realms app:
1. During or after a game, access the game log
2. Copy the entire log text
3. Paste into the tracker

## Architecture

```
app/
├── controllers/
│   └── games_controller.rb     # Handles log submission and parsing
├── services/
│   └── star_realms/
│       ├── log_parser.rb       # Main parser with regex patterns
│       └── game_result.rb      # Data object for parsed results
└── views/
    └── games/
        └── new.html.erb        # Form and chart display
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
| `=== {player} has won the game` | Winner detection |

### GameResult Object

```ruby
result = StarRealms::LogParser.parse(log_text)

result.players           # => ["Player1", "Player2"]
result.authority_by_turn # => {"Player1" => [[0, 50], [1, 50], ...]}
result.winner            # => "Player2" or nil
result.total_turns       # => 16
```

## Running Tests

```bash
# Run all tests
bin/rails test

# Run parser tests only
bin/rails test test/services/star_realms/log_parser_test.rb
```

## Development

### Adding Support for New Log Formats

1. Add a sample log to `test/fixtures/files/`
2. Write tests for expected behavior in `log_parser_test.rb`
3. Add regex patterns to `LogParser` as needed
4. Run tests to verify

### Code Style

```bash
# Run RuboCop
bin/rubocop
```

## Known Limitations

- Some game modes (like games ending via special card effects without authority attacks) may not show the final state change in the log
- Only supports 2-player games
- Does not track card acquisitions or deck composition (future feature)

## License

MIT
