# Propuesta: settings-and-arcade-polish

Incorporar música de fondo retro chiptune (BGM), un diálogo de configuración interactivo para ajustar volúmenes y preferencias sonoras/hápticas, y modernizar el diálogo de instrucciones (`InstructionsDialog`) con una estética arcade coherente con el resto del juego.

---

## Motivación

Tras la incorporación de los efectos de sonido (SFX) y hápticos en `audio-and-haptics`, los jugadores necesitan:
1. Una ambientación musical continua que aporte inmersión y ritmo durante las partidas.
2. Control fino sobre el volumen del juego (pudiendo silenciar o graduar los efectos y la música de forma independiente).
3. Una experiencia visual pulida y coherente: el actual `InstructionsDialog` utiliza estilos genéricos y fuentes estándar que desentonan con la estética arcade de 16-bit de *Stroop Focus*.

---

## Qué cambia

1. **Música de fondo en bucle (BGM)**:
   - Nuevo clip musical chiptune 8-bit en bucle continuo (`assets/audio/bgm.wav`).
   - Gestión en `AudioService` de un canal exclusivo para BGM con control de reproducción en loop (`ReleaseMode.loop`) y ajuste de volumen específico.
2. **Panel de Ajustes (Settings Dialog)**:
   - Nuevo diálogo `SettingsDialog` accesible desde el menú principal con el botón `Key('settings_button')`.
   - Controles de:
     - SFX (Activar / Silenciar + Slider de volumen 0-100%).
     - BGM (Activar / Silenciar + Slider de volumen 0-100%).
     - Vibración háptica (Activar / Silenciar).
   - Persistencia completa en `StorageService` (`shared_preferences`).
3. **Rediseño Arcade de `InstructionsDialog`**:
   - Ventana con borde estilizado arcade y tokens de tema oscuro/adaptativo.
   - Tipografía pixel art `Press Start 2P` para títulos y badges de dirección.
   - Tarjetas de dirección en 4 cuadrantes con los colores emblemáticos del Stroop y flechas nítidas.
   - Botón de cierre arcade interactivo con micro-escalado (`scale: 0.96`).

---

## Fuera de alcance

- Pistas musicales múltiples seleccionables por el usuario (se mantiene una pista retro icónica única).
- Ajustes de sensibilidad de pantalla táctil o reasignación de teclas (se programará en la fase de controles virtuales).
- Internacionalización completa de la app (se abordará en un change dedicado de i18n).

---

## Decisiones de exploración

- **Canal de BGM dedicado:** Se añade un segundo `AudioPlayer` interno en `DefaultAudioService` exclusivo para la música de fondo, de modo que los efectos de sonido (SFX) puedan reproducirse simultáneamente sin interrumpir la música.
- **Formato de pista musical:** Sintetizada en 8-bit chiptune (muestreo mono de 22kHz en loop infinito de ~10 segundos, ultra ligera y libre de derechos).
- **Estilo de modales:** Ambos modales (`SettingsDialog` e `InstructionsDialog`) compartirán la misma base estilística de contenedor arcade retro (`surfaceContainerHighest` con esquinas suaves y sombras temáticas).
