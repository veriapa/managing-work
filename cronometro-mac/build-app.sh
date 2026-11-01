#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT"

swift build -c release
APP="$ROOT/DeskClock.app"
ICONSET="$ROOT/.build/DeskClock.iconset"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp ".build/release/DeskClock" "$APP/Contents/MacOS/DeskClock"
cp "Info.plist" "$APP/Contents/Info.plist"
mkdir -p "$ICONSET"
swift Scripts/GenerateIcon.swift "$ICONSET"
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
mkdir -p "$APP/Contents/Library/LoginItems/DeskClockLoginItem.app/Contents/MacOS"
cp ".build/release/DeskClockLoginItem" "$APP/Contents/Library/LoginItems/DeskClockLoginItem.app/Contents/MacOS/DeskClockLoginItem"
cp "LoginItem-Info.plist" "$APP/Contents/Library/LoginItems/DeskClockLoginItem.app/Contents/Info.plist"
printf 'Built %s\n' "$APP"
