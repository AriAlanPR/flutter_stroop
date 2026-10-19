# Auditoría — Rediseñar o ampliar las mecánicas de juego y persistencia de datos/puntajes

- Repo: flutter_stroop · rama main · commit ed7f12f · 2026-10-18
- Alcance: código de la aplicación (`lib/`, `test/`, `pubspec.yaml`); evaluación de persistencia local y modernización del flujo de juego bajo estándares Riverpod y OpenSpec.
- Estado: fases 8/8 (completo)

## Resumen

`flutter_stroop` es un minijuego funcional basado en el efecto Stroop implementado en Flutter con Riverpod 2, pero sin persistencia de datos ni registro de estadísticas de sesión (todo reside en `StateProvider` volátiles en memoria). El núcleo de interacción (teclado y swipe) es sólido y portable, pero la arquitectura de estado y temporización sufre de fugas de ciclo de vida (`gameLogicProvider` sin `autoDispose`) y acoplamiento imperativo en la UI. Se recomienda migrar a un controlador unificado (`Notifier`), incorporar persistencia local liviana con `shared_preferences` (KISS) para récords y métricas de sesión, y estructurar el trabajo en 3 incrementos iterativos (OpenSpec).

## 1. Inventario

Fuente: `git ls-files`, 127 archivos. Comando ejecutado:

```bash
python3 .agents/skills/ciclo-descubrir/scripts/inventario.py --repo /Volumes/Cauldron/Projects/personal/flutter_stroop
```

### Conteo por lenguaje y estructura
- **Dart**: 25 archivos (2076 líneas) repartidos en `lib/` (24 archivos `.dart` + 2 imágenes en `lib/assets/images/`) y `test/` (1 archivo).
- **Plataformas**: `android/` (28 archivos), `ios/` (49 archivos), `web/` (15 archivos).
- **Manifiesto principal**: `pubspec.yaml:1-106` (`name: stroop`, SDK `^3.7.2`, dependencias `flutter_riverpod: ^2.5.1`, `google_fonts: ^6.2.1`, `vector_math: ^2.1.4`, `cupertino_icons: ^1.0.8`).

### Módulos y responsabilidades
1. **Punto de entrada y tema (`lib/main.dart:1-34`)**: Inicializa `ProviderScope` (`lib/main.dart:8-10`) y monta `MaterialApp` con tema claro fijo y `MainMenuScreen` como `home` (`lib/main.dart:19-32`).
2. **Estado y lógica de juego (`lib/providers/game_providers.dart:1-125`)**: Define los enums `GameState` (`ready`, `playing`, `gameOver` en `lib/providers/game_providers.dart:6-10`) y `Direction` (`right`, `left`, `up`, `down` en `lib/providers/game_providers.dart:13-18`), los `StateProvider` en memoria (`scoreProvider`, `timerProvider`, `currentWordProvider`, `gameStateProvider` en `lib/providers/game_providers.dart:21-27`), el mapeo fijo de 4 colores a direcciones (`lib/providers/game_providers.dart:31-39`) y `gameLogicProvider` (`lib/providers/game_providers.dart:42-115`) con temporizador periódico de 1 s, generación aleatoria de palabra/tinta y validación de respuestas. No existe capa de persistencia local ni remota.
3. **Pantallas (`lib/screens/`)**:
   - `lib/screens/main_menu_screen.dart:8-87`: Menú principal con reinicio manual de providers y navegación imperativa (`Navigator.of(context).push`) hacia juego e instrucciones (`lib/screens/main_menu_screen.dart:56-80`).
   - `lib/screens/game_screen.dart:8-153`: Pantalla activa del juego con captura de teclado (`KeyboardListener` en `lib/screens/game_screen.dart:35-52`), gestos de swipe (`GestureDetector` en `lib/screens/game_screen.dart:61-79`), marcador/reloj (`lib/screens/game_screen.dart:84-90`), palabra coloreada (`lib/screens/game_screen.dart:93-101`) y vista de fin de partida (`lib/screens/game_screen.dart:113-143`).
   - `lib/screens/instructions_screen.dart:4-94`: Pantalla estática de reglas y mapeo de colores/direcciones.
4. **Utilidades y efectos (`lib/utils/`)**:
   - `lib/utils/app_pallet.dart:3-70`: Paleta estática `AppPallet` heredada/copiada, referenciada únicamente desde `lib/utils/flutterfx/loaders_fx/loaders_fx.dart:2` (`grep -rn "flutterfx\|app_pallet\|AppPallet" lib/ test/`).
   - `lib/utils/flutterfx/` (18 archivos `.dart`): Widgets de animaciones y demos (`HyperText`, `LoaderSquare`, `LoadersFx`) sin ninguna importación desde `lib/main.dart`, `lib/screens/` ni `lib/providers/` (`grep -rn "flutterfx" lib/ test/` → sólo referencias internas en `lib/utils/flutterfx/`).

### Arranque y núcleo a conservar
- El arranque ocurre en `lib/main.dart:7-11` (`runApp(const ProviderScope(child: MyApp()))`) abriendo `MainMenuScreen` (`lib/main.dart:31`).
- El núcleo funcional actual es la mecánica Stroop en `lib/providers/game_providers.dart:31-105` (generación de estímulo palabra vs. color de tinta y evaluación contra dirección con bonificación/penalización de tiempo) junto con la entrada dual por swipe y teclado en `lib/screens/game_screen.dart:35-79`.

### Estado de tests y CI
- **Tests**: 2 archivos detectados por `inventario.py`:
  - `test/widget_test.dart:14-29`: Test de humo por defecto de Flutter (`Counter increments smoke test`) que busca `'0'` e `Icons.add`, obsoleto frente a `MainMenuScreen`.
  - `ios/RunnerTests/RunnerTests.swift:5-12`: Plantilla vacía `testExample()`.
- **CI**: Ninguna configuración reconocida en el repositorio.

## 2. Contratos y flujos clave

### Contrato central y estado del juego
- **Contrato de estado**: El juego modela su ciclo de vida con un enum simple `GameState { ready, playing, gameOver }` (`lib/providers/game_providers.dart:6-10`) y direcciones espaciales `Direction { right, left, up, down }` (`lib/providers/game_providers.dart:13-18`).
- **Estado desacoplado en providers independientes**:
  - `scoreProvider = StateProvider<int>((ref) => 0)` (`lib/providers/game_providers.dart:21`)
  - `timerProvider = StateProvider<int>((ref) => 30)` (`lib/providers/game_providers.dart:23`)
  - `currentWordProvider = StateProvider<Map<String, Color>>((ref) => {})` (`lib/providers/game_providers.dart:25`)
  - `gameStateProvider = StateProvider<GameState>((ref) => GameState.ready)` (`lib/providers/game_providers.dart:27`)
- **Contrato de la lógica (`GameLogic`)**:
  - `class GameLogic` (`lib/providers/game_providers.dart:118-125`): Expone callbacks imperativos `startGame`, `generateNewWord`, `stopGame` y `checkAnswer(Direction)`.
  - Instanciado mediante `gameLogicProvider = Provider((ref) => ...)` (`lib/providers/game_providers.dart:42-115`).
- **Registro y resolución**: Estático a través del `ProviderScope` global en la raíz (`lib/main.dart:8-10`). No hay inyección dinámica de servicios ni capa de repositorio.

### Traza Caso 1: Inicio de partida y ciclo del temporizador
1. **Acción de usuario**: En `MainMenuScreen`, el usuario pulsa "Start Game" (`lib/screens/main_menu_screen.dart:56-70`).
2. **Reinicio previo**: El botón reinicia manualmente 4 providers (`lib/screens/main_menu_screen.dart:61-64`) y navega con `Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GameScreen()))` (`lib/screens/main_menu_screen.dart:66-68`).
3. **Disparo post-frame**: En `_GameScreenState.build` (`lib/screens/game_screen.dart:25-29`), al detectar `gameState == GameState.ready`, se encola `WidgetsBinding.instance.addPostFrameCallback((_) { ref.read(gameLogicProvider).startGame(); });`.
4. **Inicialización en provider**: `GameLogic.startGame()` (`lib/providers/game_providers.dart:62-80`):
   - Cancela cualquier `gameTimer` previo (`lib/providers/game_providers.dart:63`).
   - Setea `gameState = GameState.playing`, `score = 0`, `timer = 30` (`lib/providers/game_providers.dart:66-68`).
   - Llama a `generateNewWord()` (`lib/providers/game_providers.dart:69`).
   - Crea `Timer.periodic(const Duration(seconds: 1))` (`lib/providers/game_providers.dart:71-79`).
5. **Caducidad**: En cada tick, decrementa `timerNotifier.state`. Al llegar a 0 o menos, cancela el timer y transiciona `gameStateNotifier.state = GameState.gameOver` (`lib/providers/game_providers.dart:74-78`).

### Traza Caso 2: Evaluación de respuesta por gesto o teclado
1. **Captura del estímulo**:
   - Vía teclado: `KeyboardListener.onKeyEvent` (`lib/screens/game_screen.dart:38-51`) detecta flechas del cursor (`arrowRight` → `Direction.right`, etc.).
   - Vía táctil: `GestureDetector.onHorizontalDragEnd` / `onVerticalDragEnd` (`lib/screens/game_screen.dart:61-79`) evalúa la dirección del vector de velocidad `primaryVelocity`.
2. **Invocación**: Se llama a `ref.read(gameLogicProvider).checkAnswer(direction)`.
3. **Validación de reglas** (`lib/providers/game_providers.dart:88-105`):
   - Guard de estado: Si no está en `GameState.playing` o la palabra está vacía, aborta sin cambios (`lib/providers/game_providers.dart:89-92`).
   - Mapeo de verdad: Extrae el color de tinta actual `currentWordEntry.values.first` y busca la dirección esperada en `colorDirectionMap` (`lib/providers/game_providers.dart:94-95`).
   - Acierto: `scoreNotifier.state++`; añade 2 segundos al timer con techo de 30 (`timerNotifier.state = timerNotifier.state + 2 > 30 ? 30 : timerNotifier.state + 2;` en `lib/providers/game_providers.dart:98-99`).
   - Fallo: Resta 1 segundo al timer con piso de 0 (`timerNotifier.state = timerNotifier.state - 1 < 0 ? 0 : timerNotifier.state - 1;` en `lib/providers/game_providers.dart:101`).
4. **Siguiente estímulo**: Llama a `generateNewWord()` (`lib/providers/game_providers.dart:104`), eligiendo aleatoriamente una palabra de `['RED', 'GREEN', 'BLUE', 'YELLOW']` y un color de `[Colors.red, Colors.green, Colors.blue, Colors.yellow]` (`lib/providers/game_providers.dart:55-60`).

### Traza Caso 3: Fin de partida, reinicio y salida de pantalla
1. **Transición a Game Over**: Al expirar el tiempo (`lib/providers/game_providers.dart:77`) o ser detenido, la pantalla cambia de visualización (`lib/screens/game_screen.dart:113-143`) mostrando el puntaje final `Final Score: $score` y el botón "Restart Game".
2. **Reinicio**: Al pulsar "Restart Game" (`lib/screens/game_screen.dart:120-126`), se repite la secuencia manual de reseteo de los 4 providers y se invoca directamente `startGame()`.
3. **Pérdida de datos**: El puntaje final no se compara contra ningún récord previo ni se serializa; queda sobreescrito por `0`.
4. **Comportamiento en abandono de pantalla**: Si el jugador pulsa el botón atrás del `AppBar` (`lib/screens/game_screen.dart:55-58`) a mitad de partida, la pantalla se desapila, pero `gameLogicProvider` es un `Provider` raíz sin `autoDispose` (`lib/providers/game_providers.dart:42`). En consecuencia, `ref.onDispose` (`lib/providers/game_providers.dart:51-53`) no se invoca y el `Timer.periodic` continúa corriendo en memoria hasta que el tiempo se agote.

## 3. Dependencias

| Dependencia | Versión | Dónde se usa (comando → conteo) | Clasificación para el objetivo | Alternativa en el destino |
|---|---|---|---|---|
| `flutter_riverpod` | `^2.5.1` (`pubspec.yaml:37`) | `grep -rn "flutter_riverpod" lib/ test/` → 4 archivos (`main.dart:2`, `game_providers.dart:1`, `main_menu_screen.dart:3`, `game_screen.dart:2`) | Portable | Mantener Riverpod 2.x; migrar de `StateProvider` a `Notifier` / `AsyncNotifier` para datos persistidos |
| `google_fonts` | `^6.2.1` (`pubspec.yaml:38`) | `grep -rn "google_fonts" lib/ test/` → 4 archivos (`main.dart:3`, `main_menu_screen.dart:2`, `game_screen.dart:3`, `instructions_screen.dart:2`) | Portable | Requiere verificar comportamiento offline en tiendas; empaquetar fuente Inter en assets locales si se exige offline estricto |
| `vector_math` | `^2.1.4` (`pubspec.yaml:39`) | `grep -rn "vector_math" lib/ test/` → 4 archivos en animaciones de `lib/utils/flutterfx/` | Portable / Dependiente de módulo | Mantener si se integran efectos 3D de `flutterfx`; remover si no se usan |
| `cupertino_icons` | `^1.0.8` (`pubspec.yaml:36`) | `grep -rn "CupertinoIcons" lib/ test/` → 0 archivos | Sin uso | Remover del `pubspec.yaml` para reducir dependencias no utilizadas |
| `flutter_native_splash` | `^2.4.1` (`pubspec.yaml:55`) | Configuración en `pubspec.yaml:41-43` | Herramienta de build | Portable |
| `flutter_launcher_icons` | `^0.14.1` (`pubspec.yaml:54`) | Configuración en `pubspec.yaml:45-49` | Herramienta de build | Portable |
| *Persistencia local* | *Inexistente* | No hay librería de almacenamiento en `pubspec.yaml:30-40` | Requiere incorporación | `shared_preferences` para records simples; `drift` o `hive`/`isar` si se almacena historial detallado de sesiones |
| *Efectos embebidos (`flutterfx`)* | Embebido en repo | 18 archivos `.dart` en `lib/utils/flutterfx/` | Código interno sin conectar | Decidir qué animaciones adaptar a las mecánicas de juego (p. ej. `HyperText` para transiciones de palabras) y descartar el resto |

## 4. Funcionalidades y datos

| Funcionalidad | Dónde vive | Qué depende de la plataforma | Destino |
|---|---|---|---|
| Generación de estímulo Stroop | `lib/providers/game_providers.dart:55-60` | Nada (Dart puro) | Se rediseña: estructurar modelo de datos inmutable, modos de juego (clásico, contrarreloj, racha), control de congruencia y balance de colores |
| Validación y puntuación | `lib/providers/game_providers.dart:88-105` | Nada (Dart puro) | Se rediseña: soportar combos, multiplicadores, medición de tiempo de reacción individual en milisegundos |
| Temporizador de partida | `lib/providers/game_providers.dart:71-79` | `dart:async` | Se rediseña: desacoplar de UI, soportar pausa, reanudación y cancelación limpia al cambiar de pantalla o pasar a background |
| Entrada por gestos (Swipe) | `lib/screens/game_screen.dart:61-79` | Pantalla táctil (`GestureDetector`) | Se comparte: calibrar umbrales mínimos de arrastre para evitar falsos positivos de diagonal |
| Entrada por teclado físico | `lib/screens/game_screen.dart:35-52` | Hardware de teclado (`KeyboardListener`) | Se comparte: mantener paridad desktop/web y accesibilidad |
| Pantallas de menú e instrucciones | `lib/screens/main_menu_screen.dart:8-87`, `lib/screens/instructions_screen.dart:4-94` | Flutter UI | Se rediseña: navegación declarativa, adaptación a tokens de tema claro/oscuro e integración de selector de modos y records |
| Pantalla de fin de partida | `lib/screens/game_screen.dart:113-143` | Flutter UI | Se rediseña: mostrar resumen de desempeño (aciertos, fallos, precisión %, tiempo de reacción medio) y comparación con récord personal |
| Almacenamiento y persistencia | Inexistente | Almacenamiento local del dispositivo | Nuevo: crear capa de servicio de almacenamiento (`lib/model/services/storage_service.dart`) y estado (`lib/model/state/score_state.dart`) |

### Datos y estado
- **Qué se guarda actualmente**:
  - `score` (`int`): En memoria volátil (`lib/providers/game_providers.dart:21`). Se destruye al reiniciar partida o matar la app.
  - `timer` (`int`): En memoria volátil (`lib/providers/game_providers.dart:23`).
  - `currentWord` (`Map<String, Color>`): En memoria volátil (`lib/providers/game_providers.dart:25`).
- **Qué datos de usuarios existen que migrar**: Ninguno. Al no existir persistencia previa, no hay esquemas antiguos ni migraciones de base de datos pendientes.
- **Formato destino propuesto**: Esquema JSON serializado localmente vía `shared_preferences` para récords y estadísticas acumuladas.

## 5. Riesgos

### Hechos
- Todo el estado del juego vive en 4 `StateProvider` mutables en memoria (`lib/providers/game_providers.dart:21-27`), provocando pérdida total de puntajes y récords al salir de la app.
- `gameLogicProvider` es un `Provider` raíz sin `autoDispose` (`lib/providers/game_providers.dart:42-115`); si el usuario abandona `GameScreen` hacia atrás (`lib/screens/game_screen.dart:55-58`), el `Timer.periodic` sigue corriendo en background hasta que llega a 0.
- El repositorio no cuenta con ninguna dependencia de persistencia en `pubspec.yaml:30-40` (`grep -rn "shared_preferences\|sqflite\|hive\|isar\|drift" pubspec.yaml` → 0).
- `test/widget_test.dart:14-29` está completamente desactualizado; prueba un contador con botón `Icons.add` que no existe en el proyecto.
- Los colores y estilos usan valores hexadecimales hardcodeados (`lib/main.dart:24-28`, `lib/screens/main_menu_screen.dart:20-21`, `lib/screens/game_screen.dart:54-56`), incumpliendo las reglas del workspace de no usar colores fijos y soportar modo claro/oscuro mediante tokens de tema.
- Hay 18 archivos en `lib/utils/flutterfx/` sin ninguna referencia activa desde las pantallas (`grep -rn "flutterfx" lib/screens/ lib/main.dart` → 0).

### Inferencias
- La sincronización manual del estado mediante múltiples `ref.read(...notifier).state = ...` en botones de UI (`lib/screens/main_menu_screen.dart:61-64` y `lib/screens/game_screen.dart:121-125`) es propensa a bugs de estado parcial o desalineación al agregar nuevas mecánicas (vidas, niveles, multiplicadores). Un modelo de estado unificado (`GameStateModel`) manejado por un `Notifier` resolvería la fragilidad actual.
- `HyperText` (`lib/utils/flutterfx/hyper_text.dart:5-96`) utiliza timers periódicos cada pocos milisegundos para simular decodificación de texto; si se utiliza para el estímulo principal del efecto Stroop, podría generar confusión visual o penalizar el tiempo de reacción perceptual del jugador si la animación compite con la lectura inmediata del color.
- Si se busca ampliar las mecánicas para registrar analítica o curvas de aprendizaje, registrar sólo el puntaje final será insuficiente: se requiere un modelo de sesión que guarde fecha, aciertos, fallos, tiempo medio de respuesta y modo de juego.

### No verificado
- Comportamiento de `google_fonts` en dispositivos físicos sin acceso a datos o modo avión en el primer arranque (requiere prueba de compilación en dispositivo físico desconectado o verificar si la fuente está cacheada).
- Impacto en FPS y consumo de batería de las animaciones `flutterfx` (`lib/utils/flutterfx/`) en emuladores o dispositivos de gama baja durante partidas rápidas continuas.

### Descartados
- *"El temporizador se detiene solo cuando la pantalla se destruye"*: Descartado tras revisar `lib/providers/game_providers.dart:42-53` y `lib/screens/game_screen.dart:55-58`. Al ser un provider global, no detecta el desapilado de `GameScreen` en el `Navigator`.
- *"Existen conflictos con migraciones de datos de usuarios previos"*: Descartado tras revisar `pubspec.yaml` y todo el árbol de código: no existe persistencia previa, por lo que el esquema iniciará limpio sin necesidad de migraciones retrocompatibles.

## 6. Alternativas

### Persistencia local: `shared_preferences` vs `hive_ce` / `drift`
- **Alternativa A: `shared_preferences` con serialización JSON** *(Recomendada)*:
  - *Criterio*: KISS y paridad multiplataforma inmediata (Android, iOS, Web).
  - *Ventajas*: Mínima huella de dependencias, cero código nativo complejo ni generadores de código de compilación lenta (`build_runner`). Almacena fácilmente récords numéricos y cadenas JSON de historial de sesiones.
  - *Desventajas*: No admite consultas SQL complejas (no necesarias para un juego arcade local).
- **Alternativa B: Base estructurada (`drift` / SQLite o `hive_ce`)**:
  - *Criterio*: Sobredimensionada para el estado actual (YAGNI). Requiere configuración nativa y añade overhead de mantenimiento.
- *Recomendación*: Adoptar `shared_preferences` (`lib/model/services/storage_service.dart`) abstrayendo la interfaz con un `StorageService` para permitir cambiar el motor en el futuro sin tocar la UI.

### Gestión de estado: `StateProvider` múltiple vs `Notifier` unificado
- **Alternativa A: `Notifier` / `AsyncNotifier` con modelo inmutable `GameStateModel`** *(Recomendada)*:
  - *Criterio*: Principios SRP y SoC de las reglas del proyecto (`lib/model/state/`).
  - *Ventajas*: Centraliza el reloj, puntaje, palabra actual, aciertos/fallos y persistencia en un único flujo atómico, eliminando reseteos manuales dispersos en la UI.
- **Alternativa B: Mantener 4 `StateProvider` mutables**:
  - *Criterio*: Frágil; ya genera fugas de temporizador y código duplicado en menús.

## 7. Plan incremental

| # | Incremento (change) | Depende de | Alcance | No incluye |
|---|---|---|---|---|
| 1 | `game-core-refactor` | — | Unificar lógica en `GameNotifier` (`lib/model/state/game_notifier.dart`) con modelo inmutable `GameSession`; corregir ciclo de vida del temporizador (`autoDispose` y pausa); reparar test unitario base en `test/` | Persistencia en disco, animaciones avanzadas, nuevos modos de juego |
| 2 | `local-score-persistence` | 1 | Incorporar `shared_preferences`, crear `StorageService` (`lib/model/services/storage_service.dart`), guardar récord personal (high score), total de partidas y última sesión; mostrar récord en menú principal y Game Over | Tabla de líderes en línea, autenticación de usuarios |
| 3 | `game-mechanics-stats` | 2 | Medición de tiempo de reacción individual en milisegundos, cálculo de precisión (aciertos vs fallos), diferenciación de estímulos congruentes/incongruentes, pantalla de resumen estadístico detallado y tokens de tema (soporte claro/oscuro) | Sonidos FX, modos multijugador |

### PoC (Prueba de Concepto Inicial en Incremento 1)
- **Qué valida**: Que el ciclo de vida del temporizador se detenga limpiamente al desmontar `GameScreen` y que el estado unificado responda a eventos de teclado y swipe sin fugas de memoria.
- **Criterios de aceptación medibles**:
  1. Test unitario de `GameNotifier` que verifique que el temporizador se cancela al llamar a `dispose()`.
  2. Test de widgets que compruebe que al recibir `Direction` correcta se incrementa el puntaje y se actualiza la palabra.
- **Qué no resuelve la PoC**: La retención de datos entre cierres de la app (se aborda en el Incremento 2).

## 8. Decisiones

- a) **Manejo de `lib/utils/flutterfx/`**: ¿Conservar para animaciones de transición en el juego o mover a un paquete/carpeta separada para no ensuciar el código núcleo?
  *— Si no se responde: se mantendrán aislados en `lib/utils/` y se evaluará conectar `HyperText` en la pantalla de Game Over durante el Incremento 3.*
- b) **Fuente tipográfica `google_fonts`**: ¿Mantener descarga dinámica por HTTP o empaquetar la fuente `Inter` localmente en `assets/fonts/` para garantizar funcionamiento 100% offline?
  *— Si no se responde: se mantendrá `google_fonts` en el MVP y se dejará la empaquetación local como mejora diferible.*
