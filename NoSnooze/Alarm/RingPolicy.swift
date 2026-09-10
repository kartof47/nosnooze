import Foundation

/// What just happened to a ringing alarm.
enum RingEvent {
    /// The user pressed the system Stop button.
    case stopped
    /// The user pressed "Start mission" and the app opened.
    case missionStarted
}

/// Decides when a wake-up session must ring again.
enum RingPolicy {
    static let reRingAfterStop: TimeInterval = 60
    static let backupAfterMissionStart: TimeInterval = 180

    /// Returns the time of the next ring, or nil when the session is finished.
    static func nextRing(after event: RingEvent, at now: Date, missionCompleted: Bool) -> Date? {
        nil
    }
}
