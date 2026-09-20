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
            HStack(spacing: 16) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.accent)
                    .animSlideDown(bounce: .default)
                VStack(alignment: .leading) {
                    Text("Noch")
                    Text("")
                        .animCountUp(from: 0,
                                     to: Double(dailyLoo - value),
                                     suffix: "ml"
                        )
                        .bold()
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
            .background(.accent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        } else {
            Text("Tagesziel erreicht!")
        }
    }

    var body: some View {
        if value > 0 {
            // show today facts
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: -2) {
                        Text("Heute")
                            .font(.headline)
                            .animFlipX(from: -180, to: 0)
                        Text("")
                            .animCountUp(from: 0,
                                         to: Double(value), duration: 1.2,
                                         suffix: "ml"
                                         )
                            .font(.largeTitle)
                            .bold()
                        Text("von \(dailyLoo) ml")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .animFlipX(from: -180, to: 0, duration: 0.6)
                    }
                    Spacer()
                    Text("\((value * 100) / dailyLoo)%")
                        .animSlideLeft(delay: 0.4, bounce: .default)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.white)
                        .font(.caption)
                        .background(.accent.opacity(0.8))
                        .clipShape(.capsule)
                }
                .onTapGesture {
                    showSettings.toggle()
                }

                // show missing
                Missing()
            }
            .padding()
            .sheet(isPresented: $showSettings, content: {
                SettingsView()
            })
        }
    }
}

#Preview {
    Today(value: 20)
}
