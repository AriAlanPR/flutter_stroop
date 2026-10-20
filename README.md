# Stroop Focus

Un minijuego de reflejos y agilidad mental basado en el **Efecto Stroop**, desarrollado con **Flutter** y **Riverpod**.

El Efecto Stroop pone a prueba la velocidad y precisión del procesamiento cognitivo al mostrar palabras de colores en tintas discordantes (por ejemplo, la palabra *"ROJO"* escrita en tinta azul). El objetivo es responder rápidamente identificando el **color de la tinta** e ignorando el significado del texto.

---

## Características Principales

- **Mecánica Arcade de Alta Velocidad**: Controles responsivos por gestos táctiles (swipe) y teclas de dirección en escritorio/web.
- **Temporizador Dinámico**: Bonificación de tiempo por aciertos consecutivos y penalización por errores.
- **Persistencia Local de Récords**: Registro automático del récord histórico (High Score) usando `shared_preferences`.
- **Métricas Cognitivas en Tiempo Real**:
  - Tiempo de reacción promedio en milisegundos (`Avg Time: Xms`).
  - Desglose de precisión según congruencia del estímulo (`Congruent %` vs `Incongruent %`).
- **Diseño Arcade 16-Bit**: Tipografía pixel art (`Press Start 2P`), tokens de color adaptativos para modo claro/oscuro y assets visuales temáticos.
- **Multiplataforma**: Compatible con Android, iOS y Web.

---

## Controles de Juego

| Color de Tinta | Gesto Táctil (Móvil) | Teclado (Desktop/Web) |
| :--- | :--- | :--- |
| **Rojo** | Deslizar hacia la Derecha (Swipe Right) | Flecha Derecha (`→`) |
| **Verde** | Deslizar hacia la Izquierda (Swipe Left) | Flecha Izquierda (`←`) |
| **Azul** | Deslizar hacia Arriba (Swipe Up) | Flecha Arriba (`↑`) |
| **Amarillo** | Deslizar hacia Abajo (Swipe Down) | Flecha Abajo (`↓`) |

---

## Documentación del Proyecto

Toda la documentación técnica, guías y seguimiento del proyecto se encuentra organizada en [`docs/`](docs/):

- **[`docs/backlog.md`](docs/backlog.md)**: Lista de tareas pendientes, audio/SFX y nuevas funciones.
- **[`docs/changelog.md`](docs/changelog.md)**: Historial detallado de versiones y cambios implementados.
- **[`docs/roadmap.md`](docs/roadmap.md)**: Fases de evolución y metas estratégicas del juego.
- **[`docs/observations.md`](docs/observations.md)**: Decisiones técnicas, notas de Riverpod y consideraciones de diseño.
- **[`docs/troubleshooting.md`](docs/troubleshooting.md)**: Solución de problemas comunes (launcher icons, splash screen, pods).
- **[`docs/auditoria/`](docs/auditoria/)**: Informes de auditoría inicial y análisis arquitectónico.
- **[`docs/qa/`](docs/qa/)**: Guías de QA y validación manual.

---

## Inicio Rápido (Desarrollo)

### Requisitos Previos
- Flutter SDK `^3.7.2` o superior.
- Dart SDK integrado.

### Instalación y Ejecución
```bash
# 1. Clonar el repositorio y obtener dependencias
flutter pub get

# 2. Ejecutar la suite de pruebas automatizadas
flutter test

# 3. Iniciar la aplicación en el dispositivo o emulador deseado
flutter run
```

### Comandos de Utilidad
```bash
# Generar iconos de launcher para Android/iOS
dart run flutter_launcher_icons

# Generar pantalla de bienvenida nativa (Splash)
dart run flutter_native_splash:create
```

---

## Licencia

Este proyecto está bajo desarrollo personal para fines educativos y de entretenimiento.
