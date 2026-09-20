//
//  sourcecode.swift
//  noloo
//
//  Created by Daniel Kagemann on 18.09.26.
//

import SwiftUI

struct SettingsView: View {
    /// env
    @Environment(\.dismiss) var dismiss

    /// app storage for daily goal (in ml)
    @AppStorage("DailyLoo") private var dailyLoo: Int = 2000
    @AppStorage("notification") private var remindersEnabled: Bool = false

    var body: some View {
        VStack {
            Text("Ändere das tägliche Ziel. Dies hat Auswirkungen auf die bisher eingetragenen Werte.")
                .foregroundStyle(.secondary)

            TextField("",
                      value: $dailyLoo,
                      format: .number,
                      prompt: Text("Neues Ziel..."))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title)
            Text("ml")

            Toggle(
                "Stündliche Erinnerungen",
                isOn: $remindersEnabled
            )
            .onChange(of: remindersEnabled) { _, enabled in
                Task {
                    if enabled {
                        do {
                            let granted = try await NotificationManager
                                .shared
                                .requestAuthorization()

                            guard granted else {
                                remindersEnabled = false
                                return
                            }

                            try await NotificationManager.shared.reschedule(
                                today: HydrationSnapshot(
                                    consumedML: 750,
                                    goalML: 2500
                                ),
                                tomorrowGoalML: 2500
                            )

                        } catch {
                            remindersEnabled = false
                            print("Notification error: \(error)")
                        }
                    } else {
                        await NotificationManager.shared.cancelAll()
                    }
                }
            }
            Button("Fertig") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(.accent)
            .padding(.top, 32)
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
