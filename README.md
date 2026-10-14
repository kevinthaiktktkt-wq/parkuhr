# Parkuhr – iOS-Timer mit echtem Alarm

Einfacher Timer für das Parkticket. Er klingelt über **AlarmKit** (iOS 26+) wie der Wecker der Uhr-App:
auch bei Stummschalter und Fokus, und er hört erst auf, wenn du „Stopp" drückst.
Die Restzeit steht in der **Dynamic Island** und auf dem **Sperrbildschirm**.

## Voraussetzungen

- iPhone mit **iOS 26 oder neuer** (Einstellungen > Allgemein > Info)
- Kostenloses GitHub-Konto
- Windows-PC mit [Sideloadly](https://sideloadly.io) und iTunes/iCloud (die Download-Versionen von Apple, nicht aus dem Microsoft Store)
- Kostenlose Apple-ID

## Einmalig: Bauen lassen

1. Neues GitHub-Repository anlegen (öffentlich = Builds kostenlos).
2. Diesen Ordner hineinschieben (Branch `main`):
   ```
   git init
   git add .
   git commit -m "Parkuhr"
   git branch -M main
   git remote add origin https://github.com/DEIN-NAME/parkuhr.git
   git push -u origin main
   ```
3. Im Repository auf **Actions** gehen. Der Workflow „Build IPA" startet automatisch (ca. 5–10 Minuten).
4. Nach dem Durchlauf unten bei **Artifacts** die Datei `ParkTimer-ipa` herunterladen und entpacken. Darin liegt `ParkTimer.ipa`.

## Aufs iPhone installieren

1. iPhone: **Einstellungen > Datenschutz & Sicherheit > Entwicklermodus** einschalten, Neustart bestätigen.
2. iPhone per USB an den PC anschließen, „Vertrauen" bestätigen.
3. Sideloadly öffnen, `ParkTimer.ipa` hineinziehen, Apple-ID eingeben, **Start**.
   Sideloadly vergibt dabei automatisch eigene Bundle-IDs, die Widget-Extension wird mitsigniert.
4. iPhone: **Einstellungen > Allgemein > VPN & Geräteverwaltung** > deine Apple-ID > „Vertrauen".
5. App öffnen, Alarm-Erlaubnis bestätigen, mit „1 Minute zum Testen" ausprobieren.

## Wichtig zu wissen

- Mit kostenloser Apple-ID läuft die App **7 Tage**. Danach in Sideloadly einfach noch einmal installieren (Daten bleiben erhalten), oder AltStore nutzen, der automatisch erneuert.
- Änderungen am Code: pushen, neuen Build abwarten, neu installieren.
- Falls der Build mit einem Fehler zu AlarmKit abbricht: Fehlermeldung aus dem Actions-Log kopieren und an Claude Code geben.
- Nicht getestet: Ob AlarmKit mit kostenloser Apple-ID und Sideloading auf dem Gerät alles zeigt, lässt sich nur durch Ausprobieren herausfinden. Apple verlangt dafür laut Dokumentation nur den Info.plist-Eintrag, kein Entitlement.
