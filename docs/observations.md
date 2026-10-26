# Observaciones Técnicas y Decisiones de Arquitectura — Stroop Focus

Registro de decisiones técnicas, lecciones aprendidas, consideraciones de rendimiento y notas de diseño del proyecto.

---

## 1. Arquitectura y Manejo de Estado (Riverpod)

- **Ciclo de vida del temporizador:**
  - El temporizador de juego en `GameNotifier` debe gestionarse con `Timer.periodic`.
  - Es crítico llamar a `cancel()` tanto al entrar en `GameState.gameOver` como en el callback de limpieza o al salir de la pantalla para evitar fugas de memoria y timers huérfanos disparando actualizaciones sobre estado desechado.
- **Inmutabilidad del modelo de sesión (`GameSession`):**
  - El estado de la partida se mantiene inmutable mediante `copyWith`. Los acumuladores de estadísticas (tiempos de respuesta, aciertos/fallos congruentes e incongruentes) se actualizan en cada respuesta sin mutación directa.

---

## 2. Métricas Cognitivas y Efecto Stroop

- **Clasificación de estímulos:**
  - Un estímulo es **congruente** cuando la palabra semántica coincide con el color de la tinta (ej. texto "ROJO" pintado de color rojo).
  - Un estímulo es **incongruente** cuando la palabra difiere del color de la tinta (ej. texto "AZUL" pintado de color verde).
- **Cálculo de tiempos de reacción:**
  - El tiempo de reacción se mide con `Stopwatch` o diferencias de `DateTime.now()` desde que se presenta el nuevo estímulo en pantalla hasta que el jugador ejecuta el gesto o presiona la tecla.
  - El tiempo promedio solo considera respuestas de la partida activa y se presenta en milisegundos sin decimales superfluos.

---

## 3. Principios de UI / UX y Estandarización de Temas

- **Tokens de tema y Modo Oscuro:**
  - Siguiendo las reglas de arquitectura del workspace, no se permiten colores fijos hardcodeados en los componentes de interfaz. Todos los fondos, textos, sombras y bordes deben derivarse de `Theme.of(context).colorScheme`.
  - Los colores de los chips informativos de la pantalla de fin de partida (`InfoChip`) utilizan `colorScheme.surfaceContainerHighest`, `colorScheme.onSurfaceVariant` y `colorScheme.primary` para garantizar contraste tanto en tema claro como oscuro.
- **Tipografía Google Fonts (`Press Start 2P`):**
  - La tipografía arcade retro `Press Start 2P` le da la identidad visual al juego. Se debe asegurar el manejo offline o bundling si se prevé uso 100% desconectado en producción.

---

## 4. Gestión de Assets, Iconos y Splash Nativo

- **Precedencia en `flutter_launcher_icons`:**
  - Si existe un archivo `flutter_launcher_icons.yaml` en la raíz del proyecto, tiene precedencia sobre la configuración en `pubspec.yaml`. Para evitar confusiones y duplicidad, se mantiene la configuración centralizada directamente en `pubspec.yaml`.
- **Integración de `flutter_native_splash` con fondos oscuros:**
  - Cuando se usan splash screens con artes oscuros o arcade, el parámetro `color` en `pubspec.yaml` debe coincidir exactamente con el color del borde exterior de la imagen (`#010926`). Esto evita parpadeos o marcos claros en pantallas con proporciones extendidas o tablets.
- **Formato de imágenes fuente:**
  - Las imágenes generadas se procesan a 1024×1024 en formato PNG sin canal alfa en el launcher icon (`remove_alpha_ios: true`) para cumplir con los lineamientos de App Store y Google Play.

---

## 5. Pruebas Automatizadas y Calidad

- **Paridad estricta de pruebas:**
  - Toda funcionalidad crítica (reglas del juego, cálculo de estadísticas, almacenamiento de récord y widgets interactivos) cuenta con tests unitarios y de widgets correspondientes en `test/`.
  - Los tests de UI simulan gestos y tiempos de temporizador usando `tester.pump()` y `tester.pumpAndSettle()` respetando la inyección de providers con `ProviderScope`.

---

## 6. Criterio de Animaciones y Movimiento: UI Utility vs. Game Feel (Juice)

Se adopta una separación clara entre la interfaz de navegación y las mecánicas activas de juego:

- **Interfaz de navegación, menús y modales (`flutter-movimiento` / Emil Kowalski):**
  - Aplica principios de micro-interacciones de producto y utilidades: micro-escalado en botones al presionar (`scale: 0.96`), aperturas amortiguadas con springs para modales (`InstructionsDialog`) y paneles (`GameOverView`).
  - **Interrumpibilidad estricta:** Ninguna animación de navegación debe bloquear gestos de usuario ni generar colas de eventos retrasadas.
- **Mecánicas de juego activas (Game Feel / Juicy Arcade 16-bit):**
  - **Latencia cero en el estímulo cognitivo:** El cambio de palabra/color ante cada respuesta debe ser instantáneo (corte limpio o micro-pop de ≤ 80ms) para garantizar que los tiempos de reacción medidos en milisegundos representen fielmente el desempeño cognitivo del usuario sin interferencias de transición visual.
  - **Técnicas de impacto arcade:**
    - *Screen Shake:* Sacudida sutil de la pantalla ante fallos de respuesta o agotamiento del temporizador.
    - *Palpitación de urgencia:* El contador del HUD palpita y acentúa su coloración crítica cuando el tiempo restante cae por debajo de 3 segundos.
    - *Números flotantes y feedback de combos:* Indicadores emergentes breves de puntuación (`+10`, `Streak x3`) y chispas pixel-art en rachas de aciertos sin tapar la palabra central.
