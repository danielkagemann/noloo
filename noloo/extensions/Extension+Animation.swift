import SwiftUI
import Foundation

/// Animation helpers and view modifiers for common entrance and emphasis effects.
/// Includes slide, scale, flip, and pulse animations, plus a count-up number animation.

/// Direction for slide animations.
/// - horizontal: Animates along the x-axis.
/// - vertical: Animates along the y-axis.
enum AnimationDirection {
    case horizontal
    case vertical
}

/// Configuration for spring-based (bouncy) animations.
/// Use to control response, damping, and blend duration of the spring.
struct BounceConfig {
    /// A sensible default spring configuration.
    static let `default` = BounceConfig(response: 0.35, dampingFraction: 0.5, blendDuration: 0)

    var response: Double
    var dampingFraction: Double
    var blendDuration: Double
}

extension BounceConfig {
    /// Creates a custom spring configuration.
    /// - Parameters:
    ///   - response: The stiffness and duration trade-off; lower values are snappier.
    ///   - dampingFraction: How quickly oscillations decay; lower values bounce more.
    ///   - blendDuration: Duration over which to blend changes to the response.
    /// - Returns: A `BounceConfig` with the provided parameters.
    static func custom(response: Double = 0.5, dampingFraction: Double = 0.7, blendDuration: Double = 0) -> BounceConfig {
        BounceConfig(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration)
    }
}

/// A modifier that slides a view in from an offset while fading it in.
/// Supports horizontal or vertical direction, optional delay, fixed duration, or spring bounce.
struct Slide: ViewModifier {
    @State var animate: Bool = false
    var direction: AnimationDirection
    var value: Double
    var delay: Double = 0
    var duration: Double = 0.5
    
    var bounce: BounceConfig? = nil

    /// Chooses either a spring (for bounce) or easeInOut timing, applying the configured delay.
    private var slideAnimation: Animation {
        if let bounce {
            // Use an interpolating spring to allow visible overshoot ("bounce back"). Lower damping -> more bounce.
            return .spring(response: bounce.response, dampingFraction: bounce.dampingFraction, blendDuration: bounce.blendDuration).delay(delay)
        } else {
            return .easeInOut(duration: duration).delay(delay)
        }
    }

    /// Applies offset and opacity based on internal `animate` state and starts the animation on appear.
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

/// Scales a view from 0 to 1 (zooming in) using an easeInOut animation.
struct ScaleIn: ViewModifier {
    @State var animate: Bool = false
    var delay: Double = 0
    var duration: Double = 0.5

    /// Sets initial scale to 0 and animates to full size on appear with optional delay and duration.
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

/// Rotates a view in 3D around a specified axis from `from` to `to` degrees.
struct Flip: ViewModifier {
    @State var animate: Bool = false

    var x: CGFloat = 0
    var y: CGFloat = 0
    var z: CGFloat = 0

    var from: Double
    var to: Double
    var duration: Double = 0.8
    var delay: Double = 0

    /// Applies a 3D rotation and animates between the start and end angles on appear.
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(animate ? to : from), axis: (x: x, y: y, z: z))
            .opacity(animate ? 1 : 0)
            .onAppear {
                animate = false
                withAnimation(.easeInOut(duration: duration).delay(delay)) {
                    animate = true
                }
            }
    }
}

/// Repeatedly pulses a view by scaling and changing opacity, optionally forever.
struct Pulse: ViewModifier {
    @State private var animate: Bool = false

    var fromScale: CGFloat = 1.0
    var toScale: CGFloat = 1.1
    var fromOpacity: Double = 1.0
    var toOpacity: Double = 0.9
    var duration: Double = 0.8
    var delay: Double = 0
    var repeats: Bool = true

    /// Starts a repeating easeInOut animation (with optional delay) that autoreverses between states.
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
    /// Applies a pulsing animation (scale and opacity) to the view.
    /// - Parameters:
    ///   - fromScale: Starting scale factor.
    ///   - toScale: Target scale factor.
    ///   - fromOpacity: Starting opacity.
    ///   - toOpacity: Target opacity.
    ///   - duration: Duration of a single pulse cycle.
    ///   - delay: Delay before the first animation starts.
    ///   - repeats: Whether the pulse repeats forever (default true).
    /// - Returns: The view with a pulsing animation applied.
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

    /// Scales the view in from 0 to 1.
    /// - Parameters:
    ///   - delay: Delay before starting.
    ///   - duration: Animation duration.
    /// - Returns: The view that scales in on appear.
    func animScaleIn(delay: Double = 0, duration: Double = 0.5) -> some View {
        modifier(ScaleIn(delay: delay, duration: duration))
    }

    /// Flips the view around the Y axis from `from` to `to` degrees.
    /// - Parameters:
    ///   - from: Starting angle in degrees.
    ///   - to: Target angle in degrees.
    ///   - duration: Animation duration.
    ///   - delay: Optional delay.
    /// - Returns: The view that flips around the Y axis on appear.
    func animFlipY(from: Double, to: Double, duration: Double = 0.8, delay: Double = 0) -> some View {
        modifier(Flip(y: 1, from: from, to: to, duration: duration, delay: delay))
    }

    /// Flips the view around the X axis.
    func animFlipX(from: Double, to: Double, duration: Double = 0.8, delay: Double = 0) -> some View {
        modifier(Flip(x: 1, from: from, to: to, duration: duration, delay:delay))
    }

    /// Rotates the view around the Z axis (in-plane rotation) from `from` to `to` degrees.
    func animFlipZ(from: Double, to: Double, duration: Double = 0.8, delay: Double = 0) -> some View {
        modifier(Flip(z: 1, from: from, to: to, duration: duration, delay:delay))
    }

    /// Slides the view up into place while fading in.
    /// - Parameters:
    ///   - value: The initial vertical offset (positive moves from below).
    ///   - delay: Delay before starting.
    ///   - duration: Animation duration when not using bounce.
    ///   - bounce: Optional spring configuration for a bouncy entrance.
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

    /// Slides the view down into place while fading in.
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

    /// Slides the view left into place while fading in.
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

    /// Slides the view right into place while fading in.
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

    /// Fades the view in without movement (implemented via Slide with zero offset).
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
// MARK: - Count Up Number Animation

/// Animates a numeric value over time and renders it as text using a provided formatter closure.
/// Intended to be used via `animCountUp`.
private struct CountUpModifier: AnimatableModifier {
    var value: Double
    var formatter: (Double) -> String

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func body(content: Content) -> some View {
        Text(formatter(value))
    }
}

extension View {
    /// Animates a number counting up from `from` to `to` over `duration` seconds using a FormatStyle.
    /// - Parameters:
    ///   - from: Starting value (default 0).
    ///   - to: Target value.
    ///   - duration: Animation duration in seconds (default 0.8).
    ///   - delay: Optional delay before starting.
    ///   - style: A `FormatStyle` for Double, e.g. `.number.precision(.fractionLength(0))`.
    /// - Returns: A view displaying an animated number.
    func animCountUp(from: Double = 0,
                     to: Double,
                     duration: Double = 0.8,
                     delay: Double = 0,
                     style: some Foundation.FormatStyle<Double, String> = .number) -> some View {
        animCountUp(from: from, to: to, duration: duration, delay: delay) { value in
            value.formatted(style)
        }
    }

    /// Animates a number counting up using a custom formatter closure.
    /// - Parameters mirror the style-based overload, with a formatter closure.
    func animCountUp(from: Double = 0,
                     to: Double,
                     duration: Double = 0.8,
                     delay: Double = 0,
                     formatter: @escaping (Double) -> String) -> some View {
        modifier(_CountUpWrapper(from: from, to: to, duration: duration, delay: delay, formatter: formatter))
    }
}

/// Drives the timing of the count-up by animating `current` from `from` to `to`.
private struct _CountUpWrapper: ViewModifier {
    @State private var current: Double = 0

    var from: Double
    var to: Double
    var duration: Double
    var delay: Double
    var formatter: (Double) -> String

    func body(content: Content) -> some View {
        content
            .modifier(CountUpModifier(value: current, formatter: formatter))
            .onAppear {
                current = from
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    current = to
                }
            }
    }
}
