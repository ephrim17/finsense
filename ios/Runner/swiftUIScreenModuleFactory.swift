//
//  swiftUIScreenModuleFactory.swift
//  Runner
//
//  Created by Ephrim Daniel on 18/03/26.
//

import SwiftUI

final class SwiftUIScreenFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let params = args as? [String: Any]
    let screenID = params?["screenId"] as? String ?? SwiftUIScreenID.commandDeck.rawValue
    return SwiftUIScreenPlatformView(frame: frame, screenID: screenID)
  }
}

final class SwiftUIScreenPlatformView: NSObject, FlutterPlatformView {
  private let hostedView: UIView

  init(frame: CGRect, screenID: String) {
    let rootView = SwiftUIScreenPlatformView.makeRootView(for: screenID)
    let hostingController = UIHostingController(rootView: rootView)
    hostingController.view.frame = frame
    hostingController.view.backgroundColor = .clear
    hostedView = hostingController.view
    super.init()
  }

  func view() -> UIView {
    hostedView
  }

  private static func makeRootView(for screenID: String) -> AnyView {
    guard let knownScreenID = SwiftUIScreenID(rawValue: screenID) else {
      return AnyView(UnsupportedSwiftUIScreenView(screenID: screenID))
    }
    return AnyView(SwiftUIScreenRegistry.makeScreen(for: knownScreenID))
  }
}
