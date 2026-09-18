//
//  LooItemView.swift
//  noloo
//
//  Created by Daniel Kagemann on 18.09.26.
//

import SwiftUI

struct LooItemView: View {
    
    // input
    var item: Loo
    var action: () -> Void
    
    var body: some View {
        VStack {
            HStack (spacing: -4) {
                Circle().fill(.blue).frame(width: 12)
                Circle().fill(.blue.opacity(0.4)).frame(width: 12)
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
}
