//
//  Extension+Button.swift
//  noloo
//
//  Created by Daniel Kagemann on 18.09.26.
//

import SwiftUI

private struct FlyingItem: Identifiable {
    let id = UUID()
}

private struct FlyingSymbolEffect<Symbol: View>: View {
    let symbol: Symbol

    @State private var animate = false

    var body: some View {
        symbol
            .scaleEffect(animate ? 1.15 : 0.8)
            .rotationEffect(.degrees(animate ? 25 : -10))
            .offset(
                x: animate ? 8 : 0,
                y: animate ? -70 : -5
            )
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 0.65)) {
                    animate = true
                }
            }
    }
}

private struct FlyingSymbolModifier<Symbol: View>: ViewModifier {
    let symbol: Symbol

    @State private var items: [FlyingItem] = []

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(items) { item in
                        FlyingSymbolEffect(symbol: symbol)
                            .id(item.id)
                    }
                }
                .allowsHitTesting(false)
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        spawn()
                    }
            )
    }

    private func spawn() {
        let item = FlyingItem()
        items.append(item)

        Task {
            try? await Task.sleep(for: .seconds(0.8))

            await MainActor.run {
                items.removeAll {
                    $0.id == item.id
                }
            }
        }
    }
}

extension View {
    func flyingSymbol<Symbol: View>(
        @ViewBuilder symbol: () -> Symbol
    ) -> some View {
        modifier(
            FlyingSymbolModifier(
                symbol: symbol()
            )
        )
    }
}
