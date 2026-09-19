//
//  EmptyLooView.swift
//  noloo
//
//  Created by Daniel Kagemann on 19.09.26.
//

import SwiftUI

struct EmptyLooView: View {
    var body: some View {
        Image("noloo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 128)
            .animSlideDown(bounce: .default)
        
        Text("Du hast heute noch nichts getrunken.\nFange jetzt damit an um auf Deine\nTagesmenge zu kommen.\nDiese kannst Du ändern, \nwenn Du oben tippst. ")
            .animSlideDown(value: 40, delay: 0.2)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.vertical, 32)
    }
}

#Preview {
    EmptyLooView()
}
