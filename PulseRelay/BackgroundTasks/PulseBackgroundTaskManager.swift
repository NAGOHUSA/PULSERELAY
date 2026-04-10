import BackgroundTasks
import SwiftUI
import UserNotifications

// MARK: - PulseBackgroundTaskManager

final class PulseBackgroundTaskManager {

    static let fetchTaskID = "com.pulserelay.backgroundFetch"
    static let velocityThresholdKey = "velocityThreshold"

    // MARK: - Registration

    /// Call once from `PulseRelayApp` init.
    static func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: fetchTaskID,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleRefresh(task: refreshTask)
        }
    }

    // MARK: - Scheduling

    static func scheduleBackgroundFetch() {
        let request = BGAppRefreshTaskRequest(identifier: fetchTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 min
        try? BGTaskScheduler.shared.submit(request)
    }

    // MARK: - Task Handler

    private static func handleRefresh(task: BGAppRefreshTask) {
        // Re-schedule for the next cycle
        scheduleBackgroundFetch()

        let operation = Task {
            let client = PulseClient()
            do {
                let response = try await client.fetchVelocityTrends()
                let threshold = UserDefaults.standard.double(forKey: velocityThresholdKey)
                let effectiveThreshold = threshold > 0 ? threshold : 0.80

                let breaking = response.trends.filter {
                    $0.velocityScore >= effectiveThreshold && $0.isBreaking
                }
                if !breaking.isEmpty {
                    await sendNotification(for: breaking[0])
                }
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            operation.cancel()
        }
    }

    // MARK: - Local Notification

    @MainActor
    private static func sendNotification(for trend: VelocityTrend) async {
        let content = UNMutableNotificationContent()
        content.title = "⚡ Breaking Pulse — \(trend.niche.rawValue)"
        content.body  = trend.headline
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "trend_id":   trend.id,
            "source_url": trend.sourceURL
        ]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "pulse-\(trend.id)",
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Permission Request

    static func requestNotificationPermission() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        )
    }
}
