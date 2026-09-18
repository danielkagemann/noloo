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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -2) {
                Text("Today")
                    .font(.headline)
                Text("\(value) ml").font(.title).bold()
                Text("\(dailyLoo) ml")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\((value * 100) / dailyLoo)%").bold().foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    Today(value: 210)
}
