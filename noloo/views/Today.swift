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

    /// app storage for daily goal (in ml)
    @AppStorage("DailyLoo") private var dailyLoo: Int = 2000

    @ViewBuilder
    func Missing() -> some View {
        let remaining = dailyLoo - value
        if remaining > 0 {
            Text("Only \(dailyLoo - value)ml missing. ").padding(.top, 8)
        }
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: -2) {
                    Text("Today")
                        .font(.headline)
                    Text("\(value) ml").font(.title).bold()
                    Text("von \(dailyLoo) ml")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Missing()
                }
                Spacer()
                Text("\((value * 100) / dailyLoo)%").bold().foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    Today(value: 210)
}
