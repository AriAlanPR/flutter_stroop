# Spec: score-persistence

## ADDED Requirements

### Requirement: Local Score and Statistics Storage
The system SHALL persist player high scores and gameplay statistics using `StorageService` backed by `SharedPreferences`, loading saved records at launch and updating them when a game session ends.

#### Scenario: Initial launch with no saved records defaults high score to zero
- **Given** an empty local storage with no previous gameplay records
- **When** the high score is retrieved via `StorageService`
- **Then** the returned high score is 0 and total games played is 0

#### Scenario: Achieving a score higher than current high score updates record
- **Given** an existing persisted high score of 10
- **When** a game concludes with a final score of 15
- **Then** `StorageService` saves 15 as the new high score
- **And** total games played increments by 1

#### Scenario: Achieving a score lower than current high score preserves record
- **Given** an existing persisted high score of 20
- **When** a game concludes with a final score of 12
- **Then** the persisted high score remains 20
- **And** total games played increments by 1

### Requirement: High Score Presentation in UI
The system SHALL present the persisted high score to the player in both the main menu and the game over summary screen.

#### Scenario: Main menu displays current high score
- **Given** a persisted high score of 25
- **When** the player views `MainMenuScreen`
- **Then** a high score indicator displaying 25 is rendered

#### Scenario: Game over screen indicates new high score achieved
- **Given** an initial high score of 10
- **When** the game concludes with a score of 18
- **Then** `GameOverView` displays a new high score banner or celebration indicator
