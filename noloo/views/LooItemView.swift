//
//  sourcecode.swift
//  noloo
//
//  Created by Daniel Kagemann on 18.09.26.
//

import SwiftUI

struct LooItemView: View {
    // input
    var item: Loo
    var action: () -> Void

    var waterOpacity: [Double] {
        var opacity: [Double] = [1, 1]

        if item.amount <= 20 {
            opacity = [0.2, 0.5]
        } else if item.amount <= 50 {
            opacity = [0.5, 0.5]
        } else if item.amount <= 100 {
            opacity = [0.5, 1]
        } else {
            opacity = [1, 1]
        }

        return opacity
    }

    var body: some View {
        VStack {
            HStack(spacing: -4) {
                Circle()
                    .fill(.blue.opacity(waterOpacity[0]))
                    .stroke(.black.opacity(0.05), lineWidth: 1)
                    .frame(width: 12)
                Circle()
                    .fill(.blue.opacity(waterOpacity[1]))
                    .stroke(.black.opacity(0.05), lineWidth: 1)
                    .frame(width: 12)
            }
            Text("\(item.amount) ml")
                .bold()
            Text(item.timestamp, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    LooItemView(item: .init(amount: 20)) {}
    LooItemView(item: .init(amount: 50)) {}
    LooItemView(item: .init(amount: 100)) {}
    LooItemView(item: .init(amount: 250)) {}
}
