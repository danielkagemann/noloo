//
//  sourcecode.swift
//  tageweise
//
//  Created by Daniel Kagemann on 29.12.23.
//

import SwiftUI

enum AnimationDirection {
    case horizontal
    case vertical
}

struct Slide: ViewModifier {
    @State var animate: Bool = false
    var direction: AnimationDirection
    var value: Double
    var delay: Double = 0
    var duration: Double = 0.5

    func body(content: Content) -> some View {
        content
            .offset(x: direction == .horizontal ? (animate ? 0 : value) : 0,
                    y: direction == .vertical ? (animate ? 0 : value) : 0)
            .opacity(animate ? 1 : 0)
            .onAppear {
                animate = false
                withAnimation(.easeInOut(duration: duration).delay(delay)) {
                    animate = true
                }
            }
    }
}

struct ScaleIn: ViewModifier {
    @State var animate: Bool = false
    var delay: Double = 0
    var duration: Double = 0.5

    func body(content: Content) -> some View {
        content
            .scaleEffect(animate ? 1 : 0)
            .onAppear {
                animate = false
                withAnimation(.easeInOut(duration: duration).delay(delay)) {
                    animate = true
                }
            }
    }
}

struct Flip: ViewModifier {
    @State var animate: Bool = false

    var x: CGFloat = 0
    var y: CGFloat = 0
    var z: CGFloat = 0

    var from: CGFloat
    var to: CGFloat
    var duration: CGFloat = 0.8
    var delay: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(animate ? to : from), axis: (x: x, y: y, z: z))
            .onAppear {
                animate = false
                withAnimation(.easeInOut(duration: duration).delay(delay)) {
                    animate = true
                }
            }
    }
}

extension View {
    func animScaleIn(delay: Double = 0, duration: Double = 0.5) -> some View {
        modifier(ScaleIn(delay: delay, duration: duration))
    }

    func animFlipY(from: CGFloat, to: CGFloat, duration: CGFloat = 0.8, delay: CGFloat = 0) -> some View {
        modifier(Flip(y: 1, from: from, to: to, duration: duration, delay: delay))
    }

    func animFlipX(from: CGFloat, to: CGFloat, duration: CGFloat = 0.8, delay: CGFloat = 0) -> some View {
        modifier(Flip(x: 1, from: from, to: to, duration: duration, delay:delay))
    }

    func animFlipZ(from: CGFloat, to: CGFloat, duration: CGFloat = 0.8, delay: CGFloat = 0) -> some View {
        modifier(Flip(z: 1, from: from, to: to, duration: duration, delay:delay))
    }

    func animSlideUp(value: Double = 30, delay: Double = 0) -> some View {
        modifier(Slide(direction: .vertical, value: value, delay: delay))
    }

    func animSlideDown(value: Double = 30, delay: Double = 0, duration: Double = 0.8) -> some View {
        modifier(Slide(direction: .vertical, value: -value, delay: delay, duration: duration))
    }

    func animSlideLeft(value: Double = 30, delay: Double = 0, duration: Double = 0.8) -> some View {
        modifier(Slide(direction: .horizontal, value: value, delay: delay, duration: duration))
    }

    func animSlideRight(value: Double = 30, delay: Double = 0, duration: Double = 0.8) -> some View {
        modifier(Slide(direction: .horizontal, value: -value, delay: delay, duration: duration))
    }

    func animFadeIn(delay: Double = 0, duration: Double = 0.5) -> some View {
        modifier(Slide(direction: .horizontal, value: 0, delay: delay, duration: duration))
    }
}
