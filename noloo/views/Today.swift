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
            Text("Only \(dailyLoo - value)ml missing. ").padding(.top, 8)
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
                            .animSlideRight(value: 100, delay: 0.1)
                        Text("von \(dailyLoo) ml")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .animSlideUp(delay: 0.2)
                        Missing()
                    }
                    Spacer()
                    Text("\((value * 100) / dailyLoo)%").bold().foregroundStyle(.secondary)
                        .animSlideRight(delay: 0.2 )
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
