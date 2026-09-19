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

struct BounceConfig {
    var response: Double
    var dampingFraction: Double
    var blendDuration: Double

    static let `default` = BounceConfig(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
}

extension BounceConfig {
    static func custom(response: Double = 0.5, dampingFraction: Double = 0.7, blendDuration: Double = 0) -> BounceConfig {
        BounceConfig(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration)
    }
}

struct Slide: ViewModifier {
    @State var animate: Bool = false
    var direction: AnimationDirection
    var value: Double
    var delay: Double = 0
    var duration: Double = 0.5
    
    var bounce: BounceConfig? = nil

    private var slideAnimation: Animation {
        if let bounce {
            return .spring(response: bounce.response, dampingFraction: bounce.dampingFraction, blendDuration: bounce.blendDuration).delay(delay)
        } else {
            return .easeInOut(duration: duration).delay(delay)
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(x: direction == .horizontal ? (animate ? 0 : value) : 0,
                    y: direction == .vertical ? (animate ? 0 : value) : 0)
            .opacity(animate ? 1 : 0)
            .onAppear {
                animate = false
                withAnimation(slideAnimation) {
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

    var from: Double
    var to: Double
    var duration: Double = 0.8
    var delay: Double = 0

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

struct Pulse: ViewModifier {
    @State private var animate: Bool = false

    var fromScale: CGFloat = 1.0
    var toScale: CGFloat = 1.1
    var fromOpacity: Double = 1.0
    var toOpacity: Double = 0.9
    var duration: Double = 0.8
    var delay: Double = 0
    var repeats: Bool = true

    func body(content: Content) -> some View {
        content
            .scaleEffect(animate ? toScale : fromScale)
            .opacity(animate ? toOpacity : fromOpacity)
            .onAppear {
                animate = false
                let animation = Animation.easeInOut(duration: duration)
                    .delay(delay)
                withAnimation(repeats ? animation.repeatForever(autoreverses: true) : animation) {
                    animate = true
                }
            }
    }
}

extension View {
    func animPulse(fromScale: CGFloat = 1.0,
                   toScale: CGFloat = 1.1,
                   fromOpacity: Double = 1.0,
                   toOpacity: Double = 0.9,
                   duration: Double = 0.8,
                   delay: Double = 0,
                   repeats: Bool = true) -> some View {
        modifier(Pulse(fromScale: fromScale,
                       toScale: toScale,
                       fromOpacity: fromOpacity,
                       toOpacity: toOpacity,
                       duration: duration,
                       delay: delay,
                       repeats: repeats))
    }

    func animScaleIn(delay: Double = 0, duration: Double = 0.5) -> some View {
        modifier(ScaleIn(delay: delay, duration: duration))
    }

    func animFlipY(from: Double, to: Double, duration: Double = 0.8, delay: Double = 0) -> some View {
        modifier(Flip(y: 1, from: from, to: to, duration: duration, delay: delay))
    }

    func animFlipX(from: Double, to: Double, duration: Double = 0.8, delay: Double = 0) -> some View {
        modifier(Flip(x: 1, from: from, to: to, duration: duration, delay:delay))
    }

    func animFlipZ(from: Double, to: Double, duration: Double = 0.8, delay: Double = 0) -> some View {
        modifier(Flip(z: 1, from: from, to: to, duration: duration, delay:delay))
    }

    func animSlideUp(value: Double = 30,
                     delay: Double = 0,
                     duration: Double = 0.8,
                     bounce: BounceConfig? = nil) -> some View {
        modifier(Slide(direction: .vertical,
                       value: value,
                       delay: delay,
                       duration: duration,
                       bounce: bounce))
    }

    func animSlideDown(value: Double = 30,
                       delay: Double = 0,
                       duration: Double = 0.8,
                       bounce: BounceConfig? = nil) -> some View {
        modifier(Slide(direction: .vertical,
                       value: -value,
                       delay: delay,
                       duration: duration,
                       bounce: bounce))
    }

    func animSlideLeft(value: Double = 30,
                       delay: Double = 0,
                       duration: Double = 0.8,
                       bounce: BounceConfig? = nil) -> some View {
        modifier(Slide(direction: .horizontal,
                       value: value,
                       delay: delay,
                       duration: duration,
                       bounce: bounce))
    }

    func animSlideRight(value: Double = 30,
                        delay: Double = 0,
                        duration: Double = 0.8,
                        bounce: BounceConfig? = nil) -> some View {
        modifier(Slide(direction: .horizontal,
                       value: -value,
                       delay: delay,
                       duration: duration,
                       bounce: bounce))
    }

    func animFadeIn(delay: Double = 0,
                    duration: Double = 0.5,
                    bounce: BounceConfig? = nil) -> some View {
        modifier(Slide(direction: .horizontal,
                       value: 0,
                       delay: delay,
                       duration: duration,
                       bounce: bounce))
    }
}
