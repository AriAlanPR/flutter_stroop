# game-core Specification

## Purpose
TBD - created by archiving change game-core-refactor. Update Purpose after archive.

## Requirements

### Requirement: Unified Game State Lifecycle
The system SHALL manage game session state using an immutable `GameSession` model within a Riverpod `Notifier`, supporting transitions between `ready`, `playing`, and `gameOver` states, and ensuring timer cleanup upon provider disposal.

#### Scenario: Starting a new game initializes playing session
- **Given** a game session in `ready` state
- **When** `startGame()` is invoked
- **Then** `gameState` transitions to `playing`
- **And** `score` is set to 0, `timer` is set to 30, and a non-null challenge is generated

#### Scenario: Timer decrements periodically until zero and ends game
- **Given** a game in `playing` state with remaining timer
- **When** time ticks down to 0
- **Then** `gameState` transitions to `gameOver`
- **And** the periodic timer is cancelled

#### Scenario: Leaving game cancels timer and cleans up resources
- **Given** an active game session with a running timer
- **When** the game notifier or game screen is disposed
- **Then** the active countdown timer is immediately cancelled

### Requirement: Input Evaluation and Score Adjustment
The system SHALL evaluate directional inputs (swipe or arrow keys) against the ink color of the active challenge, adjusting score, attempts, accuracy metrics, and time bonifications.

#### Scenario: Correct answer increases score and adds bonus time
- **Given** an active challenge with an ink color mapped to `Direction.right`
- **When** the user submits `Direction.right`
- **Then** `score` increments by 1
- **And** `correctAnswers` increments by 1 and `totalAttempts` increments by 1
- **And** `timer` increases by 1 second (up to maximum 99)
- **And** a new challenge is generated

#### Scenario: Incorrect answer penalizes time without increasing score
- **Given** an active challenge with an ink color mapped to `Direction.right`
- **When** the user submits `Direction.left`
- **Then** `score` remains unchanged
- **And** `correctAnswers` remains unchanged and `totalAttempts` increments by 1
- **And** `timer` decreases by 2 seconds (down to minimum 0)
- **And** a new challenge is generated

#### Scenario: Submitting input when game is not playing is ignored
- **Given** a game session in `gameOver` or `ready` state
- **When** a directional input is submitted
- **Then** the game state, score, and attempts remain unchanged
