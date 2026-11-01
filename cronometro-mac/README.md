# Cronómetro

Un cronómetro flotante para macOS, construido con SwiftUI. Su interfaz circular combina
un fondo negro, números blancos y un icono de cronómetro diseñado para la app.

## Ejecutar

Necesitas macOS y Swift 6/Xcode Command Line Tools:

```sh
./build-app.sh
open DeskClock.app
```

La ventana permanece sobre otras aplicaciones, se puede arrastrar desde cualquier zona
y aparece en todos los espacios de macOS. El cronómetro incluye inicio/pausa, reinicio
y registro de vueltas; también se puede controlar con la barra espaciadora. Abre el menú
`•••` para revisar **Abrir al iniciar sesión** o salir. La app se registra automáticamente
para abrirse al iniciar sesión la primera vez que la ejecutas; puedes desactivarlo desde
ese mismo menú.
