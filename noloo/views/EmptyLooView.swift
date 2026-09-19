//
//  EmptyLooView.swift
//  noloo
//
//  Created by Daniel Kagemann on 19.09.26.
//

import SwiftUI

struct EmptyLooView: View {
    var body: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: 84))
            .foregroundStyle(.blue)
            .animSlideUp(value:50, delay:0.3)
        Text("You should drink something.\nChoose the amount at the bottom.\nIf you want to change your goal just tap on the header. ")
            .animFlipX(from: 90, to: 0, duration: 1)
            .animSlideDown(value: 100, delay: 0.2)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.vertical, 32)
    }
}

#Preview {
    EmptyLooView()
}
