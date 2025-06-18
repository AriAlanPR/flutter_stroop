# flutter_stroop

A Flutter project implementing a Stroop Effect game. This application challenges users to identify the ink color of a word, rather than the word itself, to test cognitive processing speed and accuracy. It utilizes Flutter for cross-platform development, Riverpod for state management, and Google Fonts for custom typography.

## Game Description

The Stroop Effect demonstrates interference in reaction time of a task. In this game, words like "RED", "GREEN", "BLUE", or "YELLOW" are displayed in conflicting ink colors (e.g., the word "RED" might be displayed in blue ink). The player must quickly identify the *ink color* and respond by swiping or using arrow keys in a specific direction:

*   **Red Ink:** Swipe Right / Right Arrow Key
*   **Green Ink:** Swipe Left / Left Arrow Key
*   **Blue Ink:** Swipe Up / Up Arrow Key
*   **Yellow Ink:** Swipe Down / Down Arrow Key

The game includes a timer, tracks the player's score, and provides immediate feedback on correct or incorrect answers, adjusting the score and time accordingly.



## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Solución de Problemas (Troubleshooting)

### Error de `PathNotFoundException` con `flutter_launcher_icons`

**Problema:**
Al ejecutar `dart run flutter_launcher_icons`, puede aparecer un error `PathNotFoundException` indicando que no se encuentra un archivo de imagen, por ejemplo:
`PathNotFoundException: Cannot open file, path = 'assets/icon/icon.png' (OS Error: No such file or directory, errno = 2)`

Este error puede ser confuso, ya que la ruta de la imagen del lanzador (`image_path`) está correctamente especificada en `pubspec.yaml` (por ejemplo, `lib/assets/images/launcher.png`).

**Causa:**
El comando `dart run flutter_launcher_icons:generate -o` genera un archivo de configuración llamado `flutter_launcher_icons.yaml` en la raíz del proyecto. Este archivo tiene precedencia sobre la configuración definida en `pubspec.yaml`. Si este archivo generado contiene una ruta de imagen diferente o una configuración por defecto que busca `assets/icon/icon.png`, ignorará la configuración de `pubspec.yaml`.

**Solución:**
1.  **Eliminar el archivo de configuración generado:** Borre el archivo `flutter_launcher_icons.yaml` de la raíz de su proyecto.
2.  **Verificar `pubspec.yaml`:** Asegúrese de que la sección `flutter_launcher_icons` en su `pubspec.yaml` esté configurada correctamente con la `image_path` deseada.
    ```yaml
    flutter_launcher_icons:
      android: true
      ios: true
      image_path: "lib/assets/images/launcher.png"
      remove_alpha_ios: true # Opcional: para eliminar el canal alfa en iOS
    ```
3.  **Volver a ejecutar el comando:** Una vez eliminado el archivo `flutter_launcher_icons.yaml` y verificada la configuración en `pubspec.yaml`, ejecute de nuevo el comando para generar los iconos:
    ```bash
    dart run flutter_launcher_icons
    ```
    Esto debería resolver el `PathNotFoundException` y generar los iconos correctamente utilizando la configuración de `pubspec.yaml`.
