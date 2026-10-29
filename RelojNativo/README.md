# Reloj Nativo para macOS

Aplicación flotante de reloj para macOS con cronómetro opcional. El cronómetro se abre desde **Ventana → Cronómetro…** o con `⌘T`; la ventana principal muestra solo la hora y la fecha. Incluye icono de reloj propio.

## Descargar la aplicación

Descarga `releases/Reloj-Nativo-macOS-arm64.zip` desde este repositorio y descomprímelo. Mueve `Reloj Nativo.app` a Aplicaciones o al Escritorio y ábrelo. El paquete está compilado para Mac con Apple Silicon.

## Reconstruir desde el código

Requiere macOS y las herramientas de línea de comandos de Apple:

```bash
./build-reloj-app.sh
open "Reloj Nativo.app"
```

El código de la aplicación y el generador del icono están en `Sources/RelojNativo/`.

La aplicación se distribuye con firma ad hoc, no con Developer ID. macOS puede pedir confirmación antes de abrirla si se descargó de Internet.
