# Propuesta: audio-and-haptics

Incorporar un sistema de efectos de sonido retro (SFX estilo chiptune 8-bit) y retroalimentación háptica sensorial para enriquecer la experiencia de juego de **Stroop Focus**, con persistencia local de la preferencia de silenciado (Mute) y control accesible desde la interfaz.

---

## Motivación

*Stroop Focus* cuenta con mecánicas de juego ágiles y métricas cognitivas precisas, pero carece de respuesta auditiva y háptica inmediata. En un juego arcade de agilidad mental, el estímulo sonoro de acierto ("blip/coin") o error ("buzz") y la micro-vibración refuerzan drásticamente el *Game Feel* y permiten al jugador interiorizar su ritmo y rendimiento sin desviar la mirada del centro de la pantalla.

---

## Qué cambia

1. **Nuevo servicio `AudioService`**:
   - Manejo de clips de sonido de baja latencia con `audioplayers` para efectos de juego: acierto (`correct.wav`), fallo (`incorrect.wav`), cuenta regresiva urgente (`tick.wav`) y fin de partida (`game_over.wav`).
   - Disparo coordinado de vibraciones del sistema (`HapticFeedback`) según el tipo de evento: impacto ligero en acierto, impacto medio en error, e impacto pesado en game over.
2. **Persistencia de preferencia de sonido**:
   - Soporte en `StorageService` para almacenar el flag booleano `isSoundEnabled` (por defecto `true`).
   - Notifier reactivo `SoundSettingsNotifier` (`soundSettingsProvider`) para alternar y consultar el estado del sonido.
3. **Controles en la UI**:
   - Botón interactivo de audio (icono de volumen activado/silenciado) en `MainMenuScreen` y en la cabecera de `GameScreen`.
4. **Desacoplamiento para pruebas**:
   - Abstracción de interfaz `AudioService` inyectable vía Riverpod para permitir mocks o instancias inertes en los tests unitarios y de widgets, garantizando que la suite siga pasando sin hardware de audio.

---

## Fuera de alcance

- Música de fondo continua en bucle (BGM) para no sobrecargar el hilo de audio en sesiones cortas (se evaluará en una fase posterior).
- Controles de volumen analógico/deslizante porcentual (se mantiene simple: activado / silenciado).
- Efectos de sonido diferenciados por cada color individual.

---

## Decisiones de exploración

- **Paquete de audio:** Se adopta `audioplayers` configurado en `PlayerMode.lowLatency` para una respuesta instantánea al tap/swipe.
- **Formato de clips:** Archivos WAV sintetizados programáticamente en 8-bit chiptune (muestreo de 22.05kHz mono), ultra ligeros (< 25 KB cada uno), ubicados en `lib/assets/audio/`.
- **Hápticos nativos:** Uso directo de `HapticFeedback` de `package:flutter/services.dart` sin librerías externas adicionales.
