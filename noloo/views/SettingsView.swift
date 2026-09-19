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
