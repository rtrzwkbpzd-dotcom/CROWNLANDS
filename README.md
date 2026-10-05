# CROWNLANDS

Ein eigener RTS-Prototyp für spätere iPhone-/iPad-Veröffentlichung. Version 0.2 nutzt eine einfache 2D-Ansicht mit gezeichneten Platzhaltern. Zielplattform der Entwicklung: Godot 4.4.1 (GDScript, Compatibility-Renderer). Kein externer Asset-Download erforderlich.

## Starten

1. Godot 4.4.1 installieren.
2. `project.godot` importieren.
3. Mit F6 die Hauptszene oder mit F5 das Projekt starten.
4. Einen Arbeiter auswählen, dann Holz/Nahrung/Stein/Gold antippen. Über die Bauleiste ein Gebäude wählen und auf einen freien sichtbaren Platz tippen. Neue Einheiten im ausgewählten Rathaus, der Kaserne oder dem Bogenplatz ausbilden.
5. Mit dem Kundschafter erkunden, eine Armee aufbauen, das gegnerische Rathaus zerstören.

## Enthalten

- Eine frei erkundbare Grünlandkarte mit gezeichneten Wegen, Grasstruktur und weicherem Sichtnebel, Blau gegen Rot.
- Rathaus, vier Arbeiter und Kundschafter je Seite.
- Vier endliche Rohstoffarten; Farmen liefern im Prototyp unbegrenzt Nahrung.
- Sechs Gebäudetypen mit Bauzeiten; Baufortschritt erfordert einen anwesenden Arbeiter.
- Fünf Einheitentypen, Produktionswarteschlangen und Wohnraumbegrenzung.
- Bewegung mit A*-Wegfindung um Gebäude und Rohstofffelder, einfache Gruppenformationen, Nah-/Fernkampf, Lebenspunkte und automatische Nahbereichsverteidigung der Armee.
- Arbeiter tragen bis zu 20 Einheiten Rohstoff und bringen sie zum Rathaus, Holzlager oder zur Farm zurück, bevor das Lager den Ertrag erhält.
- KI mit eigener Wirtschaft, tatsächlichem Bau, Produktion und Angriffen.
- Sichtweite und grobes Raster für Fog of War; Feinde außerhalb aktueller Sicht werden ausgeblendet.
- Pause, Neustart und Sieg/Niederlage.
- Interaktives Einstiegstutorial für Auswahl, Rohstoffabbau, Kaserne und Einheitenproduktion; jederzeit überspringbar oder neu startbar.
- Erster mittelalterlicher 2D-Grafikstil: Rathaus mit Dach/Fachwerk, Farmbeete, Bäume und erkennbare Rohstofffelder, Figuren mit Ausrüstung sowie Holz-/Gold-Akzente im HUD. Die Formen werden direkt im Spiel gezeichnet; noch keine finalen 3D- oder Animationsassets.
- Alles lokal, ohne Anmeldung, Werbung, Tracking, Backend oder Zahlungsfunktionen.

## Steuerung

| Aktion | Touch | Maus |
|---|---|---|
| Auswählen | Einheit/Gebäude antippen | Linksklick |
| Gruppe auswählen | Finger über Gruppe ziehen | Linke Taste ziehen |
| Befehl | Mit Auswahl auf Boden/Rohstoff/Feind tippen | Linksklick auf Ziel oder Rechtsklick |
| Kamera | Zwei Finger bewegen | Mittlere Taste ziehen |
| Zoom | Zwei Finger auseinander/zusammen | Mausrad oder +/− |
| Alle Arbeiter/Armee | Gruppenknöpfe | Gruppenknöpfe |

Ein Tipp auf ein eigenes Gebäude wählt es aus; mit gewählten Arbeitern dient ein Tipp auf eine unfertige Baustelle oder fertige Farm als Arbeitsauftrag. Abwählen beendet den Bauplatzmodus. iPhone und iPad sind für Querformat vorgesehen; echte Gerätetests stehen aus.

## Aufbau

- `scripts/rules.gd`: Kosten, Werte und Gebäudedefinitionen.
- `scripts/simulation.gd`: Wirtschaft, Bau, Produktion, Kampf, KI und Sicht; ohne UI-Abhängigkeit.
- `scripts/navigation.gd`: Raster-Wegsuche mit blockierten Gebäuden und Rohstofffeldern.
- `scripts/game.gd`: gezeichnete Karte, HUD, Auswahl, Tutorial und Touch-/Mauseingabe.
- `scenes/main.tscn`: Einstiegsszene.
- `tests/smoke.gd`: deterministischer Test für Wirtschaft, Bau, KI, Produktion und Spielende.

## Tests

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/smoke.gd
godot --headless --path . --quit-after 40
```

Wirtschaft, Wegsuche, Bau, KI und Siegbedingung liefen in den vorhandenen Simulationstests mit Godot 4.4.1 unter Linux. Das Tutorial wurde danach ergänzt und braucht noch einen Lauf im Godot-Editor. Rendering und Touch auf Apple-Geräten müssen separat geprüft werden.

## iOS-Build als nächster Schritt

Für den iOS-Export wird ein Mac mit Xcode benötigt. In Godot die passenden Export-Templates installieren, unter Projekt → Export ein iOS-Preset hinzufügen und eine eigene Bundle-ID sowie Apple-Team-ID hinterlegen. Das exportierte Xcode-Projekt öffnen, Signierung konfigurieren und auf einem Gerät testen. Für TestFlight ist ein entsprechender Apple-Developer-Zugang nötig. Dieses Paket enthält keine signierte IPA und keine fertige App-Store-Veröffentlichung.

Offizielle Anleitung: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html

## Bekannte Grenzen und Ausbau

Version 0.2 bleibt ein 2D-Funktionsprototyp mit einem ersten konsistenten Zeichenstil, aber ohne endgültige Grafiken oder Animationen. Der Rasterpfadfinder plant um Gebäude und Rohstofffelder, und Arbeiter liefern ihre Ladung zurück. Es gibt keine Kavallerie, Belagerung, Zeitalter, Forschung, Audio, Kampagne, Speichern oder Multiplayer. Fernkampfschaden wird direkt angewendet. Die drei KI-Persönlichkeiten des Konzepts sind noch nicht enthalten.

Nächste Prioritäten: Tutorial im Editor durchspielen, Balance und Feedback/Audio verbessern und auf iPad/iPhone testen. Danach können 3D-Ansicht, Zeitalter und weitere Einheiten folgen. Der Name CROWNLANDS ist ein Arbeitstitel; Markenverfügbarkeit wurde nicht geprüft.
