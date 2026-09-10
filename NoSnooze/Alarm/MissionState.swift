import Foundation

/// Remembers which wake-up sessions have had their mission completed,
/// and which session the app is currently showing a mission for.
struct MissionState {
    private let defaults: UserDefaults
    private let completedKey = "completedSessions"
    private let activeKey = "activeSession"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isCompleted(_ session: String) -> Bool {
        completed.contains(session)
    }

    func markCompleted(_ session: String) {
        var sessions = completed
        sessions.insert(session)
        defaults.set(Array(sessions), forKey: completedKey)
        if activeSession == session {
            defaults.removeObject(forKey: activeKey)
        }
    }

    var activeSession: String? {
        defaults.string(forKey: activeKey)
    }

    func setActive(_ session: String) {
        defaults.set(session, forKey: activeKey)
    }

    private var completed: Set<String> {
        Set(defaults.stringArray(forKey: completedKey) ?? [])
    }
}
