# Star Realms Tracker - Project Plan

## Current Status

### Completed Features (v0.1)

- [x] Log parser extracts players, turns, authority, winner
- [x] Handles authority gains and losses
- [x] Handles negative authority (game-ending attacks)
- [x] Handles incomplete games gracefully
- [x] Web interface for pasting logs
- [x] Chart.js visualization of authority over time
- [x] Test suite with 4 sample game logs

### Known Issues

- [ ] Games ending via special win conditions (e.g., "Revealed Influence") may not show final authority change
- [ ] Chart Y-axis minimum is set to 0, doesn't show negative authority well

---

## Roadmap

### Phase 1: Parser Improvements

#### 1.1 Enhanced Win Condition Detection
- Track authority changes that occur in the same log segment as win messages
- Handle alternative win conditions (card effects, special modes)
- Parse authority from "New Authority:" format in attack lines

#### 1.2 Combat and Trade Tracking
- Track total combat dealt per turn
- Track total trade generated per turn
- Calculate average damage per turn metrics

#### 1.3 Card Tracking
- Parse "Acquired {card}" lines
- Track cards acquired per player
- Parse faction colors from `<color=#XXXXXX>` tags:
  - `#800080` = Neutral (Scouts, Vipers, Explorers)
  - `#4CC417` = Blob (green)
  - `#FF0000` = Machine Cult (red)
  - `#FFFF00` = Star Empire (yellow)
  - `#1589FF` = Trade Federation (blue)

### Phase 2: Data Persistence

#### 2.1 Game Storage
- Create `Game` model to store parsed games
- Store raw log text for re-parsing
- Store player names, winner, turn count

#### 2.2 Player Profiles
- Track games per player
- Win/loss records
- Average game length

#### 2.3 Authority History
- Store turn-by-turn authority in database
- Enable historical analysis across games

### Phase 3: Enhanced Visualization

#### 3.1 Chart Improvements
- Add data points/markers on chart
- Show hover tooltips with turn details
- Handle negative authority display properly
- Add zoom/pan for long games

#### 3.2 Game Summary Stats
- Largest single-turn damage dealt
- Most authority gained in one turn
- Turn where lead changed hands
- "Momentum" indicator

#### 3.3 Multiple Game Comparison
- Overlay multiple games on same chart
- Compare performance across games

### Phase 4: Deck Analysis

#### 4.1 Deck Composition
- Track all cards acquired
- Show faction breakdown (pie chart)
- Cards per faction

#### 4.2 Card Statistics
- Most acquired cards
- Win rate with specific cards
- Average cards acquired per game

#### 4.3 Strategy Insights
- Faction focus detection
- Ally trigger frequency estimation
- Trade vs combat card ratio

### Phase 5: User Features

#### 5.1 User Accounts
- User registration/login
- Associate games with users
- Private game history

#### 5.2 Sharing
- Shareable game links
- Public/private game toggle
- Embed code for blogs

#### 5.3 Game Import
- Bulk import multiple games
- Parse games from clipboard history
- Import from file upload

---

## Technical Debt

### Code Quality
- [ ] Add type signatures with RBS/Sorbet
- [ ] Extract chart JavaScript to Stimulus controller
- [ ] Add request specs for games controller
- [ ] Add system tests for full user flow

### Performance
- [ ] Cache parsed results
- [ ] Optimize regex patterns (benchmark)
- [ ] Consider streaming parser for very large logs

### Infrastructure
- [ ] Set up CI/CD pipeline
- [ ] Add error tracking (Sentry/Honeybadger)
- [ ] Configure production deployment (Kamal)

---

## Data Model (Future)

```
games
  id
  player_1_name: string
  player_2_name: string
  winner_name: string
  total_turns: integer
  raw_log: text
  created_at
  updated_at

authority_snapshots
  id
  game_id: references
  player_name: string
  turn: integer
  authority: integer

acquired_cards
  id
  game_id: references
  player_name: string
  card_name: string
  faction: string
  turn_acquired: integer
```

---

## API (Future)

```
POST /api/games
  - Parse and store a game
  - Returns game ID and parsed data

GET /api/games/:id
  - Retrieve parsed game data

GET /api/players/:name/stats
  - Player statistics across all games
```

---

## Contributing

1. Pick an item from the roadmap
2. Create a feature branch
3. Write tests first
4. Implement the feature
5. Submit a pull request

## Priority Legend

- **P0**: Critical - blocks core functionality
- **P1**: High - significant user value
- **P2**: Medium - nice to have
- **P3**: Low - future consideration
