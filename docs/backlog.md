# Backlog — Stroop Focus

Lista priorizada de tareas, mejoras y nuevas funcionalidades para el proyecto.

---

## Prioridad Alta (P1) — Experiencia de Juego y Audio

- [ ] **Efectos de sonido retro (SFX) y retroalimentación háptica**
  - Sonido chiptune/8-bit al acertar, fallar, bonus de tiempo y game over.
  - Vibración ligera (haptic feedback) en dispositivos móviles al equivocarse o al responder.
  - Control de activación/desactivación de sonido en menú de ajustes o pantalla principal.
- [ ] **Modos de juego adicionales**
  - **Modo Inverso (Reverse Stroop):** Responder a la palabra escrita en lugar del color de la tinta.
  - **Modo Muerte Súbita (Sudden Death):** Un único fallo o agotar el tiempo termina la partida inmediatamente.
  - **Modo Práctica / Sin Tiempo:** Modo relajado sin temporizador para familiarizarse con las direcciones y colores.
- [ ] **Accesibilidad y modo daltónico**
  - Soporte de alto contraste y patrones/iconos opcionales sobre los colores para personas con daltonismo (protanopía, deuteranopía, tritanopía).

---

## Prioridad Media (P2) — Métricas y Progresión

- [ ] **Historial y gráficos de evolución cognitiva**
  - Almacenar el historial de las últimas 20 partidas (puntaje, tiempo de reacción promedio, precisión).
  - Pantalla o modal de estadísticas con gráfica de tendencia para visualizar si el jugador mejora sus tiempos de reacción con los días.
- [ ] **Rachas de aciertos (Streaks) y multiplicadores**
  - Sistema de combos: a mayor racha de aciertos consecutivos, mayor bonificación de puntuación y efectos visuales de racha (partículas arcade).
- [ ] **Game Feel Arcade & Feedback Visual (Juice)**
  - Efecto de sacudida de pantalla (*screen shake*) sutil ante fallos o término de tiempo.
  - Palpitación visual de urgencia en el temporizador del HUD al restar < 3 segundos.
  - Indicadores emergentes flotantes de puntos y rachas (`+10`, `Streak x2`).
  - Micro-interacciones táctiles (`scale on press: 0.96`) en botones de menús y modales según `flutter-movimiento`.
- [ ] **Pantalla de ajustes (Settings)**
  - Configuración de tema (Claro / Oscuro / Sistema).
  - Selección de idioma (i18n: Español / Inglés).
  - Reasignación de sensibilidad de swipe o disposición de controles táctiles en pantalla.

---

## Prioridad Baja (P3) — Pulido, Plataformas y Social

- [ ] **Controles táctiles virtuales en pantalla (On-Screen D-Pad / Buttons)**
  - Opción de mostrar 4 botones táctiles en la parte inferior para jugadores que prefieran taps directos en vez de swipes direccionales.
- [ ] **Logros locales (Achievements)**
  - Medallas/insignias retro por hitos: "10 aciertos seguidos en incongruentes", "Tiempo de reacción inferior a 400ms", "1000 puntos totales", etc.
- [ ] **Exportación / Compartir resultado**
  - Generación de imagen o tarjeta resumen para compartir récord y estadísticas en redes sociales o mensajería.
