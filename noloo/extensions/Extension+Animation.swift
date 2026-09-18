//
//  Extension+Animation.swift
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
   var duration:Double = 0.5
   
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

enum ViewAlign {
   case left
   case right
   case center
}

struct Align: ViewModifier {
   
   var align: ViewAlign
   
   func body(content: Content) -> some View {
      if align == .left {
         HStack {
            content
            Spacer()
         }
      } else if align == .right {
         HStack {
            Spacer()
            content
         }
      } else {
         HStack {
            Spacer()
            content
            Spacer()
         }
      }
   }
}

struct ScaleIn: ViewModifier {
   @State var animate: Bool = false
   
   func body(content: Content) -> some View {
      content
         .scaleEffect(animate ? 1 : 0)
         .onAppear {
            animate = false
            withAnimation(.easeInOut(duration: 0.8)) {
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
   
   func body(content: Content) -> some View {
      content
         .rotation3DEffect(.degrees(animate ? to : from), axis: (x: x, y: y, z: z))
         .onAppear {
            animate = false
            withAnimation(.easeInOut(duration: duration)) {
               animate = true
            }
         }
   }
}

extension View {
   func scaleIn() -> some View {
      modifier(ScaleIn())
   }
   
   func flipY(from: CGFloat, to: CGFloat, duration: CGFloat = 0.8) -> some View {
      modifier(Flip(y: 1, from: from, to: to, duration: duration))
   }
   func flipX(from: CGFloat, to: CGFloat, duration: CGFloat = 0.8) -> some View {
      modifier(Flip(x: 1, from: from, to: to, duration: duration))
   }
   func flipZ(from: CGFloat, to: CGFloat, duration: CGFloat = 0.8) -> some View {
      modifier(Flip(z: 1, from: from, to: to, duration: duration))
   }

   func slideUp(value: Double = 30, delay: Double = 0) -> some View {
      modifier(Slide(direction: .vertical, value:  value, delay: delay))
   }
   
   func slideDown(value: Double = 30, delay: Double = 0) -> some View {
      modifier(Slide(direction: .vertical, value: -value, delay: delay))
   }

   func slideLeft(value: Double = 30, delay: Double = 0) -> some View {
      modifier(Slide(direction: .horizontal, value:  value, delay: delay))
   }
   
   func slideRight(value: Double = 30, delay: Double = 0) -> some View {
      modifier(Slide(direction: .horizontal, value: -value, delay: delay))
   }
   
   func fadeIn() -> some View {
      modifier(Slide(direction: .horizontal, value: 0))
   }
   
   func alignLeft() -> some View {
      modifier(Align(align: .left))
   }
   
   func alignRight() -> some View {
      modifier(Align(align: .right))
   }

   func alignCenter() -> some View {
      modifier(Align(align: .center))
   }
}
