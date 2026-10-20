# Changelog — Stroop Focus

Todos los cambios notables en este proyecto se documentan en este archivo siguiendo las convenciones de [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y versionado semántico.

---

## [Unreleased]

### Added
- Nueva identidad visual arcade con iconos nativos para Android/iOS (`launcher.png`) y pantalla de bienvenida (`splash.png`) con gamepad retro de reflejos de 4 colores y fondo azul noche profundo (`#010926`).
- Estructura centralizada y normalizada de documentación en `docs/` (`backlog.md`, `changelog.md`, `roadmap.md`, `observations.md`, `troubleshooting.md`).

---

## [1.0.0] - 2026-10-19

### Added
- **Persistencia local de récords (`local-score-persistence`)**:
  - Servicio `StorageService` implementado sobre `shared_preferences`.
  - Persistencia del récord histórico (`highScore`) entre sesiones.
  - Indicador de "HIGH SCORE: X" en el menú principal (`MainMenuScreen`).
  - Detección de "NEW HIGH SCORE!" en la pantalla de fin de partida (`GameOverView`).
- **Métricas cognitivas avanzadas (`game-mechanics-stats`)**:
  - Seguimiento del tiempo de reacción individual en milisegundos por cada respuesta.
  - Clasificación automática de estímulos según congruencia cognitiva (congruente vs. incongruente).
  - Cálculo del tiempo de reacción promedio (`averageReactionTimeMs`).
  - Cálculo de precisión diferenciada por congruencia (`congruentAccuracyPercentage` e `incongruentAccuracyPercentage`).
  - Panel de estadísticas en `GameOverView` con chips temáticos (`InfoChip`) mostrando tiempo promedio y desglose de congruencia.
- **Diálogo centralizado de instrucciones (`InstructionsDialog`)**:
  - Diálogo accesible desde el menú principal con mapeo claro de colores y direcciones de swipe/flechas.

### Changed
- **Refactorización del núcleo de juego (`game-core-refactor`)**:
  - Migración desde múltiples `StateProvider` dispersos hacia un controlador de estado unificado y testeable `GameNotifier` con Riverpod.
  - Gestión robusta y limpia del temporizador con cancelación automática y limpieza de recursos al salir de la pantalla para evitar fugas de memoria.
  - Modelo inmutable `GameSession` para representar el estado de la partida en curso.
- **Estandarización de temas (Soporte Claro / Oscuro)**:
  - Eliminación de colores hexadecimales hardcodeados en la UI.
  - Adopción completa de tokens de tema `Theme.of(context).colorScheme`.
  - Reemplazo de métodos obsoletos de opacidad (`withOpacity`) por `withValues(alpha: ...)`.

### Removed
- Eliminación de pantalla redundante `instructions_screen.dart` en favor del modal `InstructionsDialog`.
- Limpieza de referencias muertas de paletas no utilizadas en la interfaz principal.

---

## [0.1.0] - 2026-09-28

### Added
- Versión inicial del juego Stroop en Flutter.
- Temporizador básico y marcador en memoria.
- Detección de gestos de deslizamiento (swipe) y teclas de flechas para responder.
- Soporte inicial para Android, iOS y Web.
