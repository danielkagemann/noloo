//
//  sourcecode.swift
//  noloo
//
//  Created by Daniel Kagemann on 18.09.26.
//

import SwiftUI

struct Today: View {
    /// input
    let value: Int
    
    /// states
    @State private var showSettings: Bool = false

    /// app storage for daily goal (in ml)
    @AppStorage("DailyLoo") private var dailyLoo: Int = 2000

    @ViewBuilder
    func Missing() -> some View {
        let remaining = dailyLoo - value
        if remaining > 0 {
            Text("Only \(dailyLoo - value)ml missing. ")
        } else {
            Text("💧 You have reached your daily goal!")
        }
    }

    var body: some View {
        if value > 0 {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: -2) {
                        Text("Today")
                            .font(.headline)
                            .animFlipX(from: -180, to: 0)
                        Text("\(value) ml").font(.title).bold()
                            .animFlipX(from: -180, to: 0, duration: 0.5)
                        Text("von \(dailyLoo) ml")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .animFlipX(from: -180, to: 0, duration: 0.6)
                        Missing()
                            .padding(.top, 8)
                            .animFlipX(from: -180, to: 0, duration: 0.7)
                    }
                    Spacer()
                    Text("\((value * 100) / dailyLoo)%").bold().foregroundStyle(.secondary)
                        .animSlideLeft(delay: 0.4, bounce: .default)
                }
            }
            .padding()
            .onTapGesture {
                showSettings.toggle()
            }
            .sheet(isPresented: $showSettings, content: {
                SettingsView()
            })
        }
    }
}

#Preview {
    Today(value: 1)
}
