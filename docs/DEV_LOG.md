# Entwicklungs-Log

## Session 1 — 2026-07-24

- Design-ZIP ausgewertet (dunkles "Glass"-Mockup, DESIGN.md-Farbsystem, App-Icon).
- Entscheidungen mit Nutzer geklärt: natives Swift/SwiftUI (nicht Electron), Daten nur lokal (kein GitHub-Sync für Boardinhalte), normales zentriertes Fenster beim Icon-Klick (kein Popover), Dark+Light-Theme-Umschalter.
- Architekturplan erstellt und freigegeben (siehe Git-Historie / Plan-Datei).
- Auf Nutzerwunsch: `build.sh` statt Screenshot-Vorschau als Testweg festgelegt.
- Grundgerüst implementiert (Swift Package statt `.xcodeproj`, um ohne Xcode-Projektdatei robust per Kommandozeile bauen zu können):
  - Menüleisten-Icon + Fenster-Toggle (`AppDelegate`, `TasklyApp`)
  - Datenmodell + lokale JSON-Persistenz (`Board`/`BoardColumn`/`Card`/`CardLabel`/`ChecklistItem`, `TasklyStore`) inkl. Beispieldaten aus dem Mockup
  - Dark/Light-Theming (`Theme`-Protokoll, `VisualEffectView` für Glass-Header)
  - Boards-Tabs, Spalten, Karten mit Labels/Fälligkeitsdatum/Checklisten-Fortschritt
  - Drag & Drop spaltenübergreifend + Neusortierung (`Transferable`/`.draggable`/`.dropDestination`, `TasklyStore.moveCard`)
  - Karten-Detailansicht zum Bearbeiten (Titel, Beschreibung, Labels, Fälligkeitsdatum, Checkliste)
  - `build.sh` + `Packaging/Info.plist` zum Bauen/Starten ohne Xcode-Projekt

**Nächste Schritte:** Nutzer baut mit `./build.sh` auf dem Mac, meldet Compiler-Fehler oder visuelle/funktionale Abweichungen zurück (insbesondere Drag & Drop und Menüleisten-Verhalten testen, da hier nicht kompiliert werden konnte).

## Session 1 – Fix 1

- Build-Fehler gemeldet: `AppDelegate` war nicht `@MainActor`, dadurch schlug die Property-Initialisierung `let store = TasklyStore()` fehl (`TasklyStore` ist `@MainActor`-isoliert). Fix: `AppDelegate` mit `@MainActor` annotiert (üblicher/empfohlener Pattern für `NSApplicationDelegate`-Klassen unter Swift Concurrency).
