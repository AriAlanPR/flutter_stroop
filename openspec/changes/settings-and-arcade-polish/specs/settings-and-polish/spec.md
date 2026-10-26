# Capability: settings-and-polish

Background music management, audio and haptic configuration panel, and arcade visual dialog polish for Stroop Focus.

---

## ADDED Requirements

### Requirement: Background Music Loop Management
The system SHALL support looping retro 8-bit background music during active game sessions, maintaining independent volume and mute controls separate from sound effects.

#### Scenario: Background music plays continuously during gameplay
- **Given** background music is enabled in user settings
- **When** the user starts an active game session
- **Then** the background music track begins playback in loop mode
- **And** continues playing without interrupting sound effects

#### Scenario: Background music pauses or stops on game over or exit
- **Given** background music is actively playing in a game session
- **When** the game concludes in game over or the player returns to the main menu
- **Then** the background music playback is stopped or paused

### Requirement: User Settings Configuration and Persistence
The system SHALL provide an interactive settings dialog allowing the user to configure SFX volume, BGM volume, and haptic feedback, persisting all adjustments in local storage.

#### Scenario: Settings dialog displays persisted volume and toggle states
- **Given** stored audio and haptic preferences
- **When** the user opens the settings dialog
- **Then** the sliders and switches reflect the stored values for SFX, BGM, and haptics

#### Scenario: Adjusting settings updates audio output and persists values
- **Given** the settings dialog is open
- **When** the user modifies volume sliders or toggles audio switches
- **Then** the live audio parameters are updated immediately
- **And** the updated values are stored in persistent storage

### Requirement: Arcade Themed Instructions Dialog
The system SHALL present gameplay instructions using arcade-styled typography, high-contrast directional cards matching Stroop colors, and theme-adaptive dialog surfaces.

#### Scenario: Instructions dialog displays retro styled directional cards
- **Given** the user triggers the instructions dialog from the menu or game screen
- **When** the dialog renders
- **Then** all four directional color mappings (Red, Green, Blue, Yellow) are displayed with retro pixel typography and distinct color chips
- **And** closing the dialog returns focus smoothly to the calling screen
