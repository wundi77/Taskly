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

## Session 1 – Fix 2 (nach erstem erfolgreichen Build + Screenshots)

Rückmeldung anhand von Screenshots umgesetzt:

- **Karten-Detailansicht** (`CardDetailView.swift`): Standard-`Toggle`/`Picker`/`DatePicker`/`Button`-Controls durch selbst gestylte Varianten mit sichtbarem Hintergrund/Rahmen ersetzt (eigener Check-Row-Button für "Erledigt"/"Fälligkeitsdatum", Farb-Kreise statt System-Picker für Labels, rot umrandeter "Karte löschen"-Button, gefüllter "Fertig"-Button) — vorher kaum erkennbar/bedienbar auf dunklem Grund.
- **Header-Icon** (`HeaderView.swift`): helles, abgerundetes Hintergrund-Plättchen hinter dem App-Icon, damit die dunklen Bildanteile nicht mit dem Header verschmelzen.
- **Fenster-Transparenz**: `AppDelegate.swift` setzt das Fenster jetzt `isOpaque = false`/`backgroundColor = .clear`; `ContentView.swift` legt eine `NSVisualEffectView` (`.underWindowBackground`) unter ein leicht transparentes (`.opacity(0.92)`) Theme-Hintergrund-Overlay, `DarkTheme.background` von `#121212` auf `#232323` aufgehellt.
- **Dunkel/Hell-Umschalter reparlert**: der segmentierte `Picker` (der nichts tat) wurde durch zwei explizite Buttons ersetzt, die `isDarkMode` direkt setzen.
- **Board- vs. Listen-/Karten-Erstellung entflochten**: Header-Button heißt jetzt "Neues Board" und legt ein komplett neues Board an (Name direkt inline im Tab editierbar, nur per Return bestätigt; `TasklyStore.addBoard()`/`renameBoard(_:to:)`, `BoardTabsView.swift`). Die Spalten-Fußzeile heißt jetzt "+ weitere Karte" (unverändert: legt nur eine Karte in der jeweiligen Spalte an). Die "+ Weitere Liste"-Kachel zum Anlegen neuer Spalten bleibt unverändert bestehen.

**Nächste Schritte:** Nutzer baut erneut mit `./build.sh`, prüft Kontrast/Sichtbarkeit im Karten-Detail, Icon-Sichtbarkeit, Fenster-Transparenz, Dunkel/Hell-Umschaltung und das neue "Neues Board"/"+ weitere Karte"-Verhalten.

## Session 1 – Fix 3

- **Fenster wieder verschiebbar**: `newWindow.isMovableByWindowBackground = true` ergänzt (`AppDelegate.swift`) — durch die transparente Fensterkonfiguration aus Fix 2 ging das Ziehen per Titelleiste verloren.
- **Schwarzer Text im Label-Name-Feld (Dunkelmodus) behoben**: native AppKit-Controls (Eingabetext, Cursor) folgten der echten System-Erscheinung statt unserem Theme. `ContentView.swift` setzt jetzt `NSApp.appearance` passend zu `isDarkMode` (initial + bei jeder Umschaltung).
- **Rechtsklick-Menü auf dem Menüleisten-Icon** (`AppDelegate.swift`): Links-/Rechtsklick werden unterschieden; Rechtsklick zeigt ein Menü mit "Beim Start automatisch laden" (Häkchen, via `SMAppService.mainApp.register()/unregister()`) und "Beenden" (`NSApp.terminate(nil)`). Linksklick bleibt der bisherige Fenster-Toggle.

**Nächste Schritte:** Nutzer baut erneut mit `./build.sh`, prüft Fenster-Verschiebbarkeit, Lesbarkeit des Label-Name-Felds im Dunkelmodus, sowie das Rechtsklick-Menü (Login-Item-Häkchen, Beenden).

## Session 1 – Fix 4

- **Boards löschbar**: `TasklyStore.deleteBoard(_:)` ergänzt; `BoardTabsView.swift` bekommt ein Kontextmenü (Rechtsklick auf den Board-Tab) mit "Umbenennen" und "Board löschen". Wird das aktive Board gelöscht, springt die Ansicht automatisch zum nächsten verbliebenen Board (oder zeigt "Kein Board vorhanden").
- **Hauptfläche transparenter**: `BoardView.swift` malte bisher einen komplett blickdichten `theme.background` über die Spalten/Karten-Fläche, wodurch die in Fix 2 eingebaute Fenster-Transparenz dort gar nicht sichtbar war. Jetzt `theme.background.opacity(0.35)`, zusätzlich die globale Overlay-Deckkraft in `ContentView.swift` von `0.92` auf `0.75` gesenkt — der Header (eigene, unveränderte `VisualEffectView`) bleibt davon unberührt, Karten selbst bleiben unverändert deckend/lesbar.

**Nächste Schritte:** Nutzer baut erneut mit `./build.sh`, prüft Board-Löschen (Rechtsklick auf Board-Tab) und die stärkere Transparenz der Haupt-/Kartenfläche in Dunkel- und Hellmodus.

## Session 1 – Fix 5

- **Fenster-Inhalt "schwebte" bei kurzem Inhalt (z.B. leeres Board ohne Spalten)**: `ContentView.swift` gab dem Wurzel-`VStack` bisher keine `maxWidth`/`maxHeight`, wodurch SwiftUI den (kürzeren) Inhalt innerhalb des transparenten Fensters zentrierte statt ihn oben an der Titelleiste zu verankern — sichtbar als Lücke zwischen Titelleiste und Header. Fix: `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)` auf den Wurzel-Inhalt, sodass Header/Board immer oben anliegen und eventueller Leerraum unten (transparent) erscheint statt als Lücke oben.

**Nächste Schritte:** Nutzer baut erneut mit `./build.sh`, prüft insbesondere ein Board ohne Spalten (oder ein neu angelegtes Board) — Header sollte jetzt direkt unter der Titelleiste bleiben, kein Schweben mehr.

## Session 1 – Fix 6

- **Titelleiste (Ampel-Symbole + "Taskly"-Titel) komplett entfernt**: `AppDelegate.swift` erzeugt das Fenster jetzt ohne `.titled` im `styleMask` (nur noch `.resizable, .fullSizeContentView`), sodass der eigene App-Header direkt am oberen Fensterrand beginnt. Da es keine Titelleiste mehr zum Ziehen gibt, bleibt `isMovableByWindowBackground = true` bestehen — das Fenster lässt sich weiterhin per Klick auf freie Hintergrundflächen verschieben, per Rand weiterhin per Größe ziehen. Schließen/Beenden weiterhin über das Menüleisten-Icon (Klick zum Ausblenden, Rechtsklick → "Beenden").

**Nächste Schritte:** Nutzer baut erneut mit `./build.sh` — Fenster sollte jetzt ohne sichtbaren Titelleisten-Streifen direkt mit dem App-Header beginnen, weiterhin per Hintergrund verschiebbar und per Rand skalierbar sein.
