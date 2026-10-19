# Spec: game-stats

## ADDED Requirements

### Requirement: Stimulus Congruency and Reaction Time Tracking
The system SHALL classify each stimulus as congruent (word matches ink color) or incongruent (word conflicts with ink color), track reaction time in milliseconds from presentation to player response, and aggregate cognitive metrics.

#### Scenario: Congruent stimulus matching word and ink color is identified
- **Given** a stimulus challenge where word is 'RED' and ink color is `Colors.red`
- **When** the challenge is evaluated
- **Then** `isCongruent` is true
- **And** submitting an answer increments congruent attempt counters

#### Scenario: Incongruent stimulus with conflicting word and ink color is identified
- **Given** a stimulus challenge where word is 'BLUE' and ink color is `Colors.red`
- **When** the challenge is evaluated
- **Then** `isCongruent` is false
- **And** submitting an answer increments incongruent attempt counters

#### Scenario: Player response records reaction time in milliseconds
- **Given** a stimulus presented at a known timestamp
- **When** the player submits an answer 350 milliseconds later
- **Then** 350 is appended to the session's reaction times list
- **And** the average reaction time reflects the new sample

### Requirement: Post Game Cognitive Statistics Summary
The system SHALL present an expanded statistics card upon game over displaying total score, overall accuracy percentage, average reaction time in milliseconds, and cognitive interference breakdown.

#### Scenario: Game over screen displays average reaction time
- **Given** a completed game session with recorded reaction times
- **When** `GameOverView` is rendered
- **Then** an average reaction time stat chip is displayed with its millisecond value

#### Scenario: Game over screen displays cognitive congruency accuracy breakdown
- **Given** a completed game session with both congruent and incongruent trials
- **When** `GameOverView` is rendered
- **Then** separate breakdown metrics for congruent and incongruent accuracy are presented
