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
            .animSlideDown(bounce: .default)
        
        Text("You should drink something.\nChoose the amount at the bottom.\nIf you want to change your goal just tap on the header. ")
            .animSlideDown(value: 40, delay: 0.2)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.vertical, 32)
    }
}

#Preview {
    EmptyLooView()
}
