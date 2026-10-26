# Tareas: settings-and-arcade-polish

---

## 1. Persistencia extendida, modelo GameSettings y canal BGM en AudioService
- [x] 1.1 Generar pista musical chiptune en loop continuo en `assets/audio/bgm.wav` y registrar en assets
- [x] 1.2 Ampliar `StorageService` con métodos de lectura/escritura para `bgmEnabled`, `sfxVolume`, `bgmVolume` y `hapticsEnabled`
- [x] 1.3 Ampliar `AudioService` con canal dedicado para BGM (`startBgm`, `stopBgm`, `setBgmVolume`, `setSfxVolume`)
- [x] 1.4 Implementar modelo `GameSettings` y notifier reactivo `gameSettingsProvider`
- [x] 1.5 Escribir pruebas unitarias para `StorageService` y `GameSettingsNotifier` cubriendo persistencia de volúmenes y switches

---

## 2. Integración de BGM en GameNotifier y ciclo de juego
- [ ] 2.1 Disparar inicio de BGM en `startGame()` respetando si BGM está activo en settings
- [ ] 2.2 Detener reproducción de BGM al finalizar partida (`_handleGameOver`) o al limpiar recursos (`resetGame` / dispose)
- [ ] 2.3 Escribir pruebas unitarias con mock de `AudioService` en `test/audio_feedback_test.dart` cubriendo:
  - `Background music plays continuously during gameplay`
  - `Background music pauses or stops on game over or exit`

---

## 3. SettingsDialog, Rediseño Retro de InstructionsDialog y Widget Tests
- [ ] 3.1 Crear `SettingsDialog` con sliders de volumen y switches para SFX, BGM y hápticos con estética arcade
- [ ] 3.2 Rediseñar `InstructionsDialog` con tarjetas de cuadrantes para cada dirección, badges de color y tipografía `Press Start 2P`
- [ ] 3.3 Agregar botón de configuración (`Key('settings_button')`) en `MainMenuScreen`
- [ ] 3.4 Escribir widget tests cubriendo paridad de escenarios:
  - `Settings dialog displays persisted volume and toggle states`
  - `Adjusting settings updates audio output and persists values`
  - `Instructions dialog displays retro styled directional cards`
- [ ] 3.5 Verificar adaptación visual y contraste en temas claro y oscuro
