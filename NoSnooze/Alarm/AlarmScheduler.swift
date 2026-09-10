import ActivityKit
import AlarmKit
import SwiftUI

/// Data carried by every NoSnooze alarm.
struct NoSnoozeAlarmData: AlarmMetadata {
    var session: String
}

/// Thin wrapper around AlarmKit so the rest of the app never touches it directly.
enum AlarmScheduler {
    static func requestAuthorization() async -> Bool {
        let manager = AlarmManager.shared
        switch manager.authorizationState {
        case .authorized:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await manager.requestAuthorization()) == .authorized
        @unknown default:
            return false
        }
    }

    /// Reads the current permission without prompting.
    static var isAuthorized: Bool {
        AlarmManager.shared.authorizationState == .authorized
    }

    /// Schedules a single ring for `session` at `date`.
    @discardableResult
    static func scheduleRing(session: String, at date: Date) async throws -> UUID {
        let id = UUID()
        let alert = AlarmPresentation.Alert(
            title: "Wake up. Mission time.",
            stopButton: AlarmButton(text: "Stop", textColor: .white, systemImageName: "stop.fill"),
            secondaryButton: AlarmButton(text: "Start mission", textColor: .black, systemImageName: "figure.run"),
            secondaryButtonBehavior: .custom
        )
        let attributes = AlarmAttributes<NoSnoozeAlarmData>(
            presentation: AlarmPresentation(alert: alert),
            metadata: NoSnoozeAlarmData(session: session),
            tintColor: .orange
        )
        let configuration = AlarmManager.AlarmConfiguration<NoSnoozeAlarmData>(
            countdownDuration: nil,
            schedule: .fixed(date),
            attributes: attributes,
            stopIntent: StopRingIntent(alarmID: id.uuidString, session: session),
            secondaryIntent: StartMissionIntent(alarmID: id.uuidString, session: session),
            sound: .default
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        return id
    }

    /// Stops a ringing alarm; ignores alarms that already ended.
    static func stop(alarmID: String) {
        guard let id = UUID(uuidString: alarmID) else { return }
        try? AlarmManager.shared.stop(id: id)
    }

    /// Cancels every scheduled NoSnooze alarm.
    static func cancelAll() {
        for alarm in (try? AlarmManager.shared.alarms) ?? [] {
            try? AlarmManager.shared.cancel(id: alarm.id)
        }
    }

    static func scheduledCount() -> Int {
        ((try? AlarmManager.shared.alarms) ?? []).count
    }
}
