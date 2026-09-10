import SwiftUI

@main
struct NoSnoozeApp: App {
    var body: some Scene {
        WindowGroup {
            SpikeView()
                .preferredColorScheme(.dark)
        }
    }
}
