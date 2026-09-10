import Foundation
import Testing
@testable import NoSnooze

struct RingPolicyTests {
    let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func stopWithoutMissionRingsAgainAfterSixtySeconds() {
        let next = RingPolicy.nextRing(after: .stopped, at: now, missionCompleted: false)
        #expect(next == now.addingTimeInterval(60))
    }

    @Test func startingMissionArmsThreeMinuteBackup() {
        let next = RingPolicy.nextRing(after: .missionStarted, at: now, missionCompleted: false)
        #expect(next == now.addingTimeInterval(180))
    }

    @Test(arguments: [RingEvent.stopped, .missionStarted])
    func completedMissionEndsSession(event: RingEvent) {
        #expect(RingPolicy.nextRing(after: event, at: now, missionCompleted: true) == nil)
    }
}
