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
            Text("Change you daily goal. Please note that this has impact on all daily consumptions.").foregroundStyle(.secondary)

            TextField("",
                      value: $dailyLoo,
                      format: .number,
                      prompt: Text("Your new goal"))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title)
            Text("ml")

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent).tint(.accent)
            .padding(.top, 32)
        }
    }
}

#Preview {
    SettingsView()
}
