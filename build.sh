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

# Ship the designed .icns as-is (Finder/Dock icon, header logo, and menu bar
# icon are all loaded from this one file at runtime via NSImage).
cp "Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"

echo "==> Fertig. Starte ${APP_BUNDLE} ..."
open "$APP_BUNDLE"
