//
//  SwiftUIScreenRegistry.swift
//  Runner
//
//  Created by Ephrim Daniel on 18/03/26.
//

import SwiftUI

enum SwiftUIScreenRegistry {
  @ViewBuilder
  static func makeScreen(for screenID: SwiftUIScreenID) -> some View {
    switch screenID {
    case .commandDeck:
      NativeCommandDeckView()
    }
  }
}

enum SwiftUIScreenID: String {
  case commandDeck
}
