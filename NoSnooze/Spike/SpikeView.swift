import SwiftUI

/// Throwaway screen for proving the re-ring loop on a device.
struct SpikeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var authorized = false
    @State private var activeSession: String?
    @State private var scheduled = 0
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("NoSnooze test")
                .font(.largeTitle.bold())
            Text(authorized ? "Alarms allowed" : "Alarms not allowed yet")
                .foregroundStyle(authorized ? .green : .orange)
            Text("Scheduled rings: \(scheduled)")
            Text(activeSession.map { "Mission open for session \($0.prefix(8))" } ?? "No mission open")
                .foregroundStyle(.secondary)

            Button("Allow alarms") {
                Task { authorized = await AlarmScheduler.requestAuthorization() }
            }
            Button("Ring in 1 minute") {
                Task { await ringSoon() }
            }
            .disabled(!authorized)
            Button("I did the mission") {
                completeMission()
            }
            .disabled(activeSession == nil)
            .tint(.green)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .onAppear(perform: refresh)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
    }

    private func refresh() {
        activeSession = MissionState().activeSession
        scheduled = AlarmScheduler.scheduledCount()
        authorized = AlarmScheduler.isAuthorized
    }

    private func ringSoon() async {
        do {
            try await AlarmScheduler.scheduleRing(session: UUID().uuidString, at: .now.addingTimeInterval(60))
            message = "Ring scheduled. Lock the phone."
        } catch {
            message = "Scheduling failed: \(error.localizedDescription)"
        }
        refresh()
    }

    private func completeMission() {
        guard let session = activeSession else { return }
        MissionState().markCompleted(session)
        AlarmScheduler.cancelAll()
        message = "Mission done. No more rings."
        refresh()
    }
}
