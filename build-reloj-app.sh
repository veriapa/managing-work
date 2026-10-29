#!/bin/bash
set -euo pipefail

APP_NAME="Reloj Nativo"
EXECUTABLE="RelojNativo"
BUILD_EXECUTABLE=".RelojNativo-bin"
ICONSET=".RelojNativo.iconset"
ICON_PNG=".RelojNativo-icon.png"

swiftc -swift-version 5 -O -framework AppKit \
    Sources/RelojNativo/main.swift \
    -o "$BUILD_EXECUTABLE"
swift Sources/RelojNativo/IconGenerator.swift "$ICON_PNG"

rm -rf "$APP_NAME.app" "$ICONSET"
mkdir -p "$APP_NAME.app/Contents/MacOS" "$APP_NAME.app/Contents/Resources"
cp "$BUILD_EXECUTABLE" "$APP_NAME.app/Contents/MacOS/$EXECUTABLE"

mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$ICON_PNG" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    double_size=$((size * 2))
    sips -z "$double_size" "$double_size" "$ICON_PNG" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP_NAME.app/Contents/Resources/$EXECUTABLE.icns"
rm -rf "$ICONSET"
rm -f "$ICON_PNG"

cat > "$APP_NAME.app/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundleDisplayName</key><string>$APP_NAME</string>
    <key>CFBundleExecutable</key><string>$EXECUTABLE</string>
    <key>CFBundleIdentifier</key><string>cl.odonto.relojnativo</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>NSHighResolutionCapable</key><true/>
PLIST

if [[ -f "$APP_NAME.app/Contents/Resources/$EXECUTABLE.icns" ]]; then
    printf '%s\n' "    <key>CFBundleIconFile</key><string>$EXECUTABLE</string>" >> "$APP_NAME.app/Contents/Info.plist"
fi
printf '%s\n' '</dict>' '</plist>' >> "$APP_NAME.app/Contents/Info.plist"
rm -f "$BUILD_EXECUTABLE"

echo "\"$APP_NAME.app\" creado."
