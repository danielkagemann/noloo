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
    var week: [Date:Int] {
        items.lastWeekAmount()
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(week.sorted(by: { $0.key < $1.key }), id: \.key) { date, value in
                VStack {
                    Text(date.toFormat("EEE"))
                        .font(.caption)
                        .bold()
                    Text("\(value)ml")
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: true, vertical: false)
                        .fontWeight(value < dailyLoo ? .regular : .bold)
                }
                .padding(4)
                .frame(minHeight: 56, alignment: .center)
                .background(.accent.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LastDaysView()
}
