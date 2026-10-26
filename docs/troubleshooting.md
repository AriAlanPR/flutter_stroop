# Guía de Solución de Problemas (Troubleshooting) — Stroop Focus

Resolución de incidencias comunes de compilación, generación de assets y entorno de desarrollo.

---

## 1. Error `PathNotFoundException` al generar launcher icons

### Síntoma
Al ejecutar:
```bash
dart run flutter_launcher_icons
```
Se produce un error similar a:
```
PathNotFoundException: Cannot open file, path = 'assets/icon/icon.png' (OS Error: No such file or directory, errno = 2)
```
A pesar de que en `pubspec.yaml` la ruta `image_path` está configurada correctamente en `lib/assets/images/launcher.png`.

### Causa
Si previamente se corrió `flutter_launcher_icons:generate -o`, se genera un archivo `flutter_launcher_icons.yaml` en la raíz del proyecto. Este archivo tiene precedencia sobre `pubspec.yaml` y busca por defecto `assets/icon/icon.png`.

### Solución
1. Eliminar el archivo suelto si existe:
   ```bash
   rm flutter_launcher_icons.yaml
   ```
2. Verificar que en `pubspec.yaml` esté la configuración correcta:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "lib/assets/images/launcher.png"
     remove_alpha_ios: true
   ```
3. Volver a ejecutar el comando:
   ```bash
   dart run flutter_launcher_icons
   ```

---

## 2. Marco blanco en la pantalla de bienvenida (Splash Screen)

### Síntoma
En pantallas largas o dispositivos con aspecto 20:9 o tablets, se aprecia un borde o recuadro blanco alrededor del logo de bienvenida en lugar de un fondo uniforme.

### Solución
Asegurar que la clave `color` en la sección `flutter_native_splash` de `pubspec.yaml` coincida exactamente con el color perimetral de la imagen (`#010926`):
```yaml
flutter_native_splash:
  color: "#010926"
  image: lib/assets/images/splash.png
```
Y regenerar el splash nativo:
```bash
dart run flutter_native_splash:create
```

---

## 3. Discrepancias o advertencias con CocoaPods en iOS

### Síntoma
Advertencias al compilar o generar pods para iOS relacionadas con versiones de despliegue o sincronización de `Podfile.lock`.

### Solución
Ejecutar desde el directorio del proyecto:
```bash
cd ios && pod install --repo-update && cd ..
```
O ejecutar una limpieza completa de Flutter:
```bash
flutter clean
flutter pub get
```
