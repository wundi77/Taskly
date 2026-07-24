# Taskly

Native macOS-Menüleisten-App für Kanban-artige Aufgabenverwaltung (Swift/SwiftUI). Klick auf das Menüleisten-Icon zeigt ein zentriertes Fenster mit deinen Boards; erneuter Klick blendet es wieder aus. Mehrere Boards, Spalten mit Karten, Drag & Drop (spaltenübergreifend und zur Neusortierung innerhalb einer Spalte), Karten mit Labels/Fälligkeitsdatum/Checkliste, Dark- und Light-Theme.

Das visuelle Design orientiert sich möglichst genau an einem mitgelieferten Mockup (dunkles "Glass"-Design mit Deep-Teal-Akzenten, siehe `docs/ARCHITECTURE.md`).

## Voraussetzungen

- macOS 13 (Ventura) oder neuer
- Xcode-Kommandozeilenwerkzeuge (für `swift build`) — entweder volles Xcode oder `xcode-select --install`

## Bauen & Starten

```bash
git clone <repo-url>
cd Taskly
./build.sh
```

`build.sh` baut das Projekt per Swift Package Manager (`swift build -c release`), packt daraus ein `Taskly.app`-Bundle (inkl. generiertem App-Icon) und startet die App automatisch. Bei einem Build-Fehler bricht das Skript ab und zeigt die Fehlermeldung von `swiftc` an.

Da diese App **keine Xcode-Projektdatei** verwendet (reines Swift-Package), kannst du den Ordner alternativ auch direkt in Xcode öffnen (`File > Open…` auf den Ordner mit der `Package.swift`) und von dort bauen/debuggen.

## Daten

Boards/Spalten/Karten werden **nur lokal** als JSON unter `~/Library/Application Support/Taskly/boards.json` gespeichert. Es findet keine Synchronisation mit GitHub statt — im Repository liegt ausschließlich der Quellcode.

## Projektstruktur

Siehe `docs/ARCHITECTURE.md` für die Architektur (Menüleisten-Fenster-Logik, Datenmodell, Drag & Drop, Theming) sowie `docs/DEV_LOG.md` für den Entwicklungsverlauf.

## Bekannte Einschränkungen

- Die App ist unsigniert (kein Apple-Entwickler-Zertifikat) — beim ersten Start ggf. über Systemeinstellungen > Datenschutz & Sicherheit freigeben, falls Gatekeeper warnt.
- Entwickelt/geschrieben ohne lokalen Mac-Compiler-Zugriff; Compiler-Fehler oder visuelle Abweichungen bitte zurückmelden.
