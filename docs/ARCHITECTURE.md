# Architektur

## Überblick

Taskly ist ein reines Swift Package (kein `.xcodeproj`), gebaut mit `swift build` und zu einem `.app`-Bundle verpackt via `build.sh`. Das vermeidet fragile, von Hand gepflegte Xcode-Projektdateien und lässt sich vollständig über die Kommandozeile bauen.

```
Sources/Taskly/
  App/            TasklyApp.swift (SwiftUI @main), AppDelegate.swift (Menüleiste + Fenster)
  Models/         Board, BoardColumn, Card, CardLabel, ChecklistItem, CardTransferItem
  Persistence/    TasklyStore (ObservableObject, JSON-Laden/Speichern, Mutationen)
  Theme/          Theme-Protokoll, DarkTheme/LightTheme, Environment-Key, VisualEffectView
  Views/
    Root/         ContentView (Theme-Auswahl), HeaderView
    Board/        BoardTabsView, BoardView, ColumnView, AddColumnView
    Card/         CardView, LabelChipView, CardDetailView, ChecklistEditView
    Common/       SearchFieldView, PillButton
```

## Menüleisten-Fenster

`AppDelegate` hält ein `NSStatusItem` (Icon: SF-Symbol "checklist") und ein einzelnes `NSWindow`. Klick auf das Icon ruft `toggleWindow()`: ist das Fenster sichtbar, wird es geschlossen; sonst wird es (einmalig erzeugt, danach wiederverwendet) zentriert und in den Vordergrund gebracht. Wichtige Details:

- `LSUIElement = YES` (Info.plist) + `NSApp.setActivationPolicy(.accessory)` → kein Dock-Icon.
- `window.isReleasedWhenClosed = false` → die Fensterreferenz bleibt nach dem Schließen erhalten (sonst würde AppKit das Fenster deallozieren und ein erneuter Klick müsste ein komplett neues Fenster bauen).
- `NSApp.activate(ignoringOtherApps: true)` beim Anzeigen, da Accessory-Apps nicht automatisch aktivieren.
- `TasklyApp` nutzt eine leere `Settings {}`-Scene nur als SwiftUI-Lifecycle-Pflichtanker; keine `WindowGroup`, die unkontrolliert eigene Fenster erzeugen würde.

## Datenmodell & Persistenz

`Board → BoardColumn → Card` als einfache `Codable`-Structs (kein SwiftData, um macOS-13-Kompatibilität und leicht nachvollziehbaren Code ohne Compiler-Zugriff zu behalten). `TasklyStore: ObservableObject` lädt/speichert `[Board]` als JSON unter `~/Library/Application Support/Taskly/boards.json`. Beim ersten Start werden Beispieldaten (angelehnt an das Mockup: "Website Relaunch" mit den Spalten In Bearbeitung/Review/Fertig) erzeugt.

Reihenfolge von Spalten und Karten wird über ein fraktionales `order: Double`-Feld abgebildet: Beim Einfügen zwischen zwei Nachbarn wird der Mittelwert ihrer `order`-Werte berechnet, an den Rändern ±1 addiert/subtrahiert. Das vermeidet Neu-Nummerierung aller Geschwister bei jeder Verschiebung.

Alle Mutationen (Karten/Spalten/Boards hinzufügen, umbenennen, löschen, verschieben) laufen zentral über Methoden auf `TasklyStore`, die am Ende jeweils `save()` aufrufen — Views müssen nie selbst ans Speichern denken.

**Wichtiges Value-Type-Fallstrick:** `Board`/`BoardColumn`/`Card` sind Structs, verschachtelt in Arrays innerhalb von `@Published var boards`. Änderungen dürfen nur über `TasklyStore`-Methoden erfolgen, die direkt auf `boards[...]`-Indexpfade zugreifen — niemals über eine lokale Kopie in einer View mutieren und erwarten, dass es persistiert wird.

## Drag & Drop

`CardTransferItem` (Karten-ID + Quellspalten-ID) conforms `Transferable` (via `CodableRepresentation` mit einer eigenen UTI `com.wunderwald.taskly.card`, deklariert in `Packaging/Info.plist` unter `UTExportedTypeDeclarations`). Jede Karte ist `.draggable(...)`; sowohl jede Karte als auch der leere Bereich am Spaltenende sind `.dropDestination(for: CardTransferItem.self)`. `TasklyStore.moveCard(...)` ist die einzige Stelle, die die Reihenfolge neu berechnet.

**Bekannte Fehlerquelle Nr. 1**, falls Drag & Drop kompiliert, aber nichts passiert: die UTI-Deklaration in `Packaging/Info.plist` fehlt oder ist falsch geschrieben.

## Theming

`Theme`-Protokoll mit `DarkTheme`/`LightTheme`, injiziert über einen Environment-Key (`\.theme`), gesteuert per `@AppStorage("isDarkMode")` und einem Segmented-Control ("Dunkel"/"Hell") im Header — unabhängig vom System-Erscheinungsbild. Der transluzente Glass-Header nutzt `NSVisualEffectView` (via `NSViewRepresentable`), dessen `NSAppearance` explizit passend zum In-App-Theme gesetzt wird (nicht dem System-Modus folgend), damit die Blur-Tönung immer zum gewählten Taskly-Theme passt.

## Bauen ohne Xcode-Projekt

`build.sh`: `swift build -c release` → Binary wird in ein frisches `Taskly.app`-Bundle kopiert (`Contents/MacOS`, `Contents/Info.plist` aus `Packaging/Info.plist`, `Contents/Resources/AppIcon.png` + generiertes `.icns` via `sips`/`iconutil`) → `open Taskly.app`.

## Bekannte Risiken / offene Punkte

- Exakte Signaturen von `.dropDestination`/`.draggable` (macOS-13-SDK) wurden nach bestem Wissen geschrieben, konnten hier aber nicht kompiliert werden — bei Compiler-Fehlern hier zuerst nachsehen (Xcode-Autovervollständigung/Quick Help prüfen). Fallback: klassisches `NSItemProvider` + `.onDrag`/`.onDrop`.
- Schrift: aktuell Systemschrift (San Francisco) statt Inter, um das Risiko von Font-Bundling-Problemen (PostScript-Namen) zu vermeiden. Bei Bedarf später nachrüstbar.
- App ist unsigniert; lokale Builds sollten ohne Gatekeeper-Probleme laufen, da sie nicht aus dem Internet heruntergeladen (kein Quarantäne-Flag) wurden.
