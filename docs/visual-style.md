# CROWNLANDS – visuelle Zielrichtung

Die vom Projektinhaber gezeigte Referenz und die daraufhin erstellte CROWNLANDS-Stilprobe legen die Zielrichtung fest: ein gut lesbares, stilisiertes mittelalterliches Echtzeit-Strategiespiel in einer isometrischen 3D-Ansicht. Die Stilprobe ist Konzeptkunst und kein Screenshot oder bereits vorhandenes Spielasset.

## Bildsprache

- **Kamera:** feste schräge Draufsicht mit orthografischer Projektion; Zoom und Verschieben per Touch. Gebäude und Einheiten bleiben auch auf dem iPhone gut unterscheidbar.
- **Gebäude:** eigenständige Silhouetten und Funktionen. Das Rathaus hat Steinunterbau, Fachwerk und ein hohes Dach; Häuser sind kleiner; Farmen zeigen Felder und Ernte; Holzfällerhütte, Steinbruch und Eisenhütte sind schon an ihrem Material und Arbeitsbereich erkennbar.
- **Gelände:** sanfte Höhenunterschiede, Wege zwischen Gebäuden, Wiesen, gruppierte Bäume, Felsen und Felder. Schatten und warme Beleuchtung geben Tiefe, ohne die Einheiten zu verdecken.
- **Einheiten:** kurze, klare Animationen für Laufen, Sammeln, Bauen und Kämpfen; Teamfarbe an Kleidung, Bannern und Auswahlmarkierung statt vollflächig gefärbter Figuren.
- **Oberfläche:** Ressourcen oben, Auswahl und Befehle unten. Große Touch-Ziele und wenig Text über der Karte. Nebel verdeckt Unentdecktes, lässt erkundetes Gelände aber lesbar.
- **Eigenständigkeit:** Die Referenz dient nur für Stil und Lesbarkeit. Architektur, Einheiten, Karten, UI und Symbole werden für CROWNLANDS neu gestaltet.

## Technische Umsetzung in Etappen

1. **3D-Stiltest:** eine kleine begehbare Karte mit orthografischer Kamera, Rathaus, Haus, Farm, Bäumen, vier Arbeitern und sichtbaren Schatten. Zuerst nur Platzhaltermodelle, dann einheitliche eigene Assets.
2. **Spielkern anbinden:** vorhandene Simulation für Auswahl, Bewegung, Sammeln und Bauen weiterverwenden; Weltkoordinaten konsistent in die 3D-Szene abbilden. Touch-Befehle über Treffer auf Gelände, Einheiten und Gebäude.
3. **Erste spielbare Runde:** weitere Wirtschaftsgebäude, Kaserne und Kampf in diesem Stil; danach Effekte, Animationen und Optimierung für iPhone/iPad.

Der bisherige `game.gd`-Renderer ist ein funktionaler 2D-Prototyp. Er definiert nicht mehr den Ziel-Look. Der zuvor vorgeschlagene gezeichnete 2D-Stil wurde deshalb nicht in `main` übernommen.
