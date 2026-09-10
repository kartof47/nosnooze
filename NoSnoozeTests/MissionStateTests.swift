import Foundation
import Testing
@testable import NoSnooze

struct MissionStateTests {
    let state = MissionState(defaults: UserDefaults(suiteName: "test-\(UUID().uuidString)")!)

    @Test func newSessionIsNotCompleted() {
        #expect(!state.isCompleted("a"))
    }

    @Test func markingCompletedIsRemembered() {
        state.markCompleted("a")
        #expect(state.isCompleted("a"))
        #expect(!state.isCompleted("b"))
    }

    @Test func activeSessionIsClearedWhenItCompletes() {
        state.setActive("a")
        #expect(state.activeSession == "a")
        state.markCompleted("a")
        #expect(state.activeSession == nil)
    }

    @Test func completingAnotherSessionKeepsTheActiveOne() {
        state.setActive("a")
        state.markCompleted("b")
        #expect(state.activeSession == "a")
    }
}
