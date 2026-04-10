import SwiftUI
import SwiftData

@main
struct PulseRelayApp: App {

    // MARK: - SwiftData Container

    private let modelContainer: ModelContainer = {
        let schema = Schema([SelectedNiche.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()

    // MARK: - Init

    init() {
        // Register background fetch tasks
        PulseBackgroundTaskManager.registerTasks()
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .task {
                    await PulseBackgroundTaskManager.requestNotificationPermission()
                    PulseBackgroundTaskManager.scheduleBackgroundFetch()
                }
        }
    }
}
