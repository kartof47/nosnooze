import AppIntents
import Foundation

/// Attached to the alarm's Stop button. Stopping silences this ring, but the
/// session rings again unless its mission is already done.
struct StopRingIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop alarm"
    static var isDiscoverable = false

    @Parameter(title: "Alarm ID") var alarmID: String
    @Parameter(title: "Session") var session: String

    init() {
        alarmID = ""
        session = ""
    }

    init(alarmID: String, session: String) {
        self.alarmID = alarmID
        self.session = session
    }

    func perform() async throws -> some IntentResult {
        AlarmScheduler.stop(alarmID: alarmID)
        let completed = MissionState().isCompleted(session)
        if let next = RingPolicy.nextRing(after: .stopped, at: .now, missionCompleted: completed) {
            try await AlarmScheduler.scheduleRing(session: session, at: next)
        }
        return .result()
    }
}

/// Attached to the "Start mission" button. Opens the app on the mission and
/// arms a backup ring in case the user falls back asleep.
struct StartMissionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start mission"
    static var openAppWhenRun = true
    static var isDiscoverable = false

    @Parameter(title: "Alarm ID") var alarmID: String
    @Parameter(title: "Session") var session: String

    init() {
        alarmID = ""
        session = ""
    }

    init(alarmID: String, session: String) {
        self.alarmID = alarmID
        self.session = session
    }

    func perform() async throws -> some IntentResult {
        AlarmScheduler.stop(alarmID: alarmID)
        let state = MissionState()
        state.setActive(session)
        if let backup = RingPolicy.nextRing(after: .missionStarted, at: .now, missionCompleted: state.isCompleted(session)) {
            try await AlarmScheduler.scheduleRing(session: session, at: backup)
        }
        return .result()
    }
}
