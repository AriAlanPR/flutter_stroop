# Tareas: audio-and-haptics

---

## 1. Persistencia de configuración, AudioService y assets de sonido
- [x] 1.1 Agregar dependencia `audioplayers` y registrar carpeta de assets en `pubspec.yaml`
- [x] 1.2 Generar clips de sonido sintetizados retro 8-bit en `lib/assets/audio/` (`correct.wav`, `incorrect.wav`, `game_over.wav`, `tick.wav`)
- [x] 1.3 Ampliar `StorageService` con persistencia de preferencia de sonido (`isSoundEnabled` y `setSoundEnabled`)
- [x] 1.4 Crear `AudioService` con métodos de reproducción y respuesta háptica desacoplados
- [x] 1.5 Crear `soundSettingsProvider` para el control reactivo del estado de audio
- [x] 1.6 Escribir pruebas unitarias para `StorageService` y `SoundSettingsNotifier` cubriendo:
  - `Sound is enabled by default on initial launch`
  - `Toggling sound persists muted state and suppresses playback`

---

## 2. Integración de audio y respuesta háptica en el flujo de juego
- [x] 2.1 Conectar `AudioService` con `GameNotifier` respetando la inyección de dependencias para testabilidad
- [x] 2.2 Disparar sonido positivo e impacto háptico ligero en respuestas correctas
- [x] 2.3 Disparar sonido de error e impacto háptico medio en respuestas incorrectas
- [x] 2.4 Disparar sonido de fin de partida e impacto háptico pesado al agotarse el tiempo
- [x] 2.5 Escribir pruebas unitarias con mock de `AudioService` en `game_notifier_test.dart` cubriendo:
  - `Correct response triggers positive sound and light haptic`
  - `Incorrect response triggers error sound and medium haptic`
  - `Game over triggers game over sound and heavy haptic`

---

## 3. Controles en UI, Widget Tests y Validación de Tema
- [ ] 3.1 Agregar botón de alternar sonido (`Key('sound_toggle_button')`) en `MainMenuScreen`
- [ ] 3.2 Agregar botón de alternar sonido (`Key('sound_toggle_button_game')`) en la barra superior de `GameScreen`
- [ ] 3.3 Escribir widget test para verificar el cambio reactivo del icono de audio cubriendo:
  - `Toggling sound in UI updates icon state`
- [ ] 3.4 Verificar contraste visual y adaptación de los iconos en tema claro y oscuro
