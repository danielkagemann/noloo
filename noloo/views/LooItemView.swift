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
        VStack(alignment: .leading, spacing: 6) {
            Text("\(item.amount) ml")
                .font(.headline)
            Text(item.timestamp, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.accent.opacity(0.1))
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
