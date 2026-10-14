import AlarmKit
import Observation
import SwiftUI

/// Startet und beendet den Parkuhr-Alarm über AlarmKit.
/// AlarmKit klingelt auch bei Stummschalter und Fokus, bis man "Stopp" drückt,
/// und zeigt den Countdown in Dynamic Island und auf dem Sperrbildschirm.
@MainActor
@Observable
final class ParkTimerStore {
    /// Zeitpunkt, an dem der Alarm klingelt. nil = kein Timer aktiv.
    var endDate: Date?
    var errorText: String?

    private var alarmID: UUID?
    private let defaults = UserDefaults.standard

    init() {
        if let text = defaults.string(forKey: "alarmID") {
            alarmID = UUID(uuidString: text)
        }
        endDate = defaults.object(forKey: "endDate") as? Date

        // Alter, längst abgelaufener Eintrag (z. B. Alarm wurde am Sperrbildschirm gestoppt): aufräumen.
        if let end = endDate, end.timeIntervalSinceNow < -30 * 60 {
            clear()
        }
    }

    func start(minutes: Int, label: String) async {
        errorText = nil
        let manager = AlarmManager.shared

        do {
            let authorization = try await manager.requestAuthorization()
            guard authorization == .authorized else {
                errorText = "Alarme sind nicht erlaubt. Bitte unter Einstellungen > Parkuhr aktivieren."
                return
            }

            let alert = AlarmPresentation.Alert(
                title: "Parkuhr abgelaufen!",
                stopButton: AlarmButton(text: "Stopp", textColor: .white, systemImageName: "stop.circle")
            )
            let countdown = AlarmPresentation.Countdown(
                title: "Parkuhr",
                pauseButton: AlarmButton(text: "Pause", textColor: .white, systemImageName: "pause.fill")
            )
            let paused = AlarmPresentation.Paused(
                title: "Pausiert",
                resumeButton: AlarmButton(text: "Weiter", textColor: .white, systemImageName: "play.fill")
            )

            let attributes = AlarmAttributes(
                presentation: AlarmPresentation(alert: alert, countdown: countdown, paused: paused),
                metadata: ParkMetadata(label: label),
                tintColor: .orange
            )

            let duration = TimeInterval(minutes * 60)
            let configuration = AlarmManager.AlarmConfiguration.timer(
                duration: duration,
                attributes: attributes
            )

            let id = UUID()
            _ = try await manager.schedule(id: id, configuration: configuration)

            let end = Date.now.addingTimeInterval(duration)
            alarmID = id
            endDate = end
            defaults.set(id.uuidString, forKey: "alarmID")
            defaults.set(end, forKey: "endDate")
        } catch {
            errorText = "Timer konnte nicht gestartet werden: \(error.localizedDescription)"
        }
    }

    /// Bricht den laufenden Timer ab bzw. stoppt den klingelnden Alarm.
    func stopAndClear() {
        if let id = alarmID {
            try? AlarmManager.shared.stop(id: id)
            try? AlarmManager.shared.cancel(id: id)
        }
        clear()
    }

    private func clear() {
        alarmID = nil
        endDate = nil
        defaults.removeObject(forKey: "alarmID")
        defaults.removeObject(forKey: "endDate")
    }
}
