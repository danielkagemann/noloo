//
//  Extension+Alignment.swift
//  noloo
//
//  Created by Daniel Kagemann on 19.09.26.
//
import SwiftUI

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

extension View {
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
