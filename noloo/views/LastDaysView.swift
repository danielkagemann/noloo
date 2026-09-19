//
//  sourcecode.swift
//  noloo
//
//  Created by Daniel Kagemann on 19.09.26.
//

import SwiftData
import SwiftUI

struct LastDaysView: View {
    /// app storage for daily goal (in ml)
    @AppStorage("DailyLoo") private var dailyLoo: Int = 2000

    /// query
    @Query var items: [Loo]

    /// get the last 7 days
    var week: [Int] {
        items.lastWeekAmount()
    }

    var body: some View {
        HStack {
            ForEach(week, id: \.self) { val in
                VStack {
                    if val < dailyLoo {
                        Text("☔️")
                    } else {
                        Text("💧")
                    }
                    Text("\(val)ml")
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LastDaysView()
}
