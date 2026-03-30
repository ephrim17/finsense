import Flutter
import SwiftUI

enum SwiftUIScreenRegistry {
  @ViewBuilder
  static func makeScreen(
    for screenID: SwiftUIScreenID,
    financeTabBarModel: FinanceTabBarModel?,
    channel: FlutterMethodChannel,
    tabBarHeight: Double
  ) -> some View {
    switch screenID {
    case .commandDeck:
      NativeCommandDeckView()
    case .financeTabBar:
      if let financeTabBarModel {
        FinanceTabBarView(
          model: financeTabBarModel,
          tabBarHeight: tabBarHeight,
          onTabSelected: { index in
            channel.invokeMethod("tabSelected", arguments: ["index": index])
          }
        )
      } else {
        UnsupportedSwiftUIScreenView(screenID: screenID.rawValue)
      }
    }
  }
}

enum SwiftUIScreenID: String {
  case commandDeck
  case financeTabBar
}
