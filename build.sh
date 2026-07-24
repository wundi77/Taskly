#!/bin/bash
# Builds Taskly via Swift Package Manager and assembles a runnable Taskly.app
# bundle (no Xcode project needed). Run this on your Mac from the repo root:
#
#   ./build.sh
#
# On success it opens Taskly.app automatically. On failure it prints the
# swift build error output — copy that back for a fix.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="Taskly"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

echo "==> Baue ${APP_NAME} (swift build -c release) ..."
swift build -c release

BIN_PATH="$(swift build -c release --show-bin-path)/${APP_NAME}"
if [ ! -f "$BIN_PATH" ]; then
    echo "Fehler: Binary wurde nicht gefunden unter ${BIN_PATH}"
    exit 1
fi

echo "==> Baue App-Bundle ${APP_BUNDLE} ..."
rm -rf "$APP_BUNDLE"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "$BIN_PATH" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp "Packaging/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"

# Plain PNG copy, used at runtime by HeaderView to show the logo next to "Taskly".
cp "Resources/AppIcon.png" "${APP_BUNDLE}/Contents/Resources/AppIcon.png"

# Build a proper multi-resolution .icns from the source PNG for the Finder/Dock
# icon (iconutil/sips are macOS-only tools, available on your Mac at build time).
if command -v iconutil >/dev/null 2>&1 && command -v sips >/dev/null 2>&1; then
    ICONSET_DIR="$(mktemp -d)/AppIcon.iconset"
    mkdir -p "$ICONSET_DIR"
    for size in 16 32 128 256 512; do
        sips -z $size $size "Resources/AppIcon.png" --out "${ICONSET_DIR}/icon_${size}x${size}.png" >/dev/null
        double=$((size * 2))
        sips -z $double $double "Resources/AppIcon.png" --out "${ICONSET_DIR}/icon_${size}x${size}@2x.png" >/dev/null
    done
    iconutil -c icns "$ICONSET_DIR" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf "$(dirname "$ICONSET_DIR")"
else
    echo "Hinweis: iconutil/sips nicht gefunden, überspringe .icns-Erzeugung (App funktioniert trotzdem)."
fi

echo "==> Fertig. Starte ${APP_BUNDLE} ..."
open "$APP_BUNDLE"
