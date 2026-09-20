//
//  NotificationManager.swift
//  noloo
//
//  Created by Daniel Kagemann on 20.09.26.
//

import Foundation
import UserNotifications

struct HydrationSnapshot {
    let consumedML: Int
    let goalML: Int
}

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let calendar = Calendar.current

    private let identifierPrefix = "noloo.hydration."
    private let firstHour = 7
    private let lastHour = 20

    private init() {}

    // MARK: - Permission

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(
            options: [.alert, .badge, .sound]
        )
    }

    // MARK: - Scheduling

    func reschedule(
        today: HydrationSnapshot,
        tomorrowGoalML: Int,
        now: Date = .now
    ) async throws {
        // Nur unsere eigenen Notifications entfernen.
        let pending = await center.pendingNotificationRequests()

        let identifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }

        center.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )

        let todayStart = calendar.startOfDay(for: now)

        // Heute + morgen planen.
        for dayOffset in 0..<2 {
            guard let day = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: todayStart
            ) else {
                continue
            }

            let snapshot = dayOffset == 0
                ? today
                : HydrationSnapshot(
                    consumedML: 0,
                    goalML: tomorrowGoalML
                )

            // Ziel heute erreicht? Keine weiteren Erinnerungen.
            if snapshot.consumedML >= snapshot.goalML {
                continue
            }

            guard snapshot.goalML > 0 else {
                continue
            }

            for hour in firstHour...lastHour {
                guard let fireDate = calendar.date(
                    bySettingHour: hour,
                    minute: 0,
                    second: 0,
                    of: day
                ) else {
                    continue
                }

                // Vergangene Uhrzeiten überspringen.
                guard fireDate > now else {
                    continue
                }

                let content = UNMutableNotificationContent()
                content.title = "Noloo 💧"
                content.body = notificationText(
                    snapshot: snapshot,
                    hour: hour
                )
                content.sound = .default

                let components = calendar.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: fireDate
                )

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: components,
                    repeats: false
                )

                let identifier = identifierPrefix
                    + "\(Int(fireDate.timeIntervalSince1970))"

                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: content,
                    trigger: trigger
                )

                try await center.add(request)
            }
        }
    }

    // MARK: - Dynamic Text

    private func notificationText(
        snapshot: HydrationSnapshot,
        hour: Int
    ) -> String {
        let consumed = max(snapshot.consumedML, 0)
        let goal = snapshot.goalML
        let remaining = max(goal - consumed, 0)

        let progress = Double(consumed) / Double(goal)

        switch (hour, progress) {
        case (20..., _):
            return "Heute fehlen dir noch \(remaining) ml. " +
                   "Denk daran, regelmäßig zu trinken."

        case (14..., ..<0.35):
            return "Du hast heute erst \(consumed) ml getrunken. " +
                   "Ein Glas Wasser wäre jetzt eine gute Idee."

        case (_, 0.8...):
            return "Fast geschafft! Nur noch \(remaining) ml " +
                   "bis zu deinem Tagesziel."

        case (_, 0.5...):
            return "Du hast bereits \(consumed) ml getrunken. " +
                   "Weiter so!"

        default:
            return "Zeit für eine kleine Trinkpause! 💧 " +
                   "Noch \(remaining) ml bis zu deinem Ziel."
        }
    }

    // MARK: - Disable

    func cancelAll() async {
        let pending = await center.pendingNotificationRequests()

        let identifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }

        center.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }
}

