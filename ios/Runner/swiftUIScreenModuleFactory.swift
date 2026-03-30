import Flutter
import SwiftUI

final class SwiftUIScreenFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

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
    let selectedIndex = params?["selectedIndex"] as? Int ?? 0
    let tabBarHeight = params?["tabBarHeight"] as? Double ?? 83

    return SwiftUIScreenPlatformView(
      frame: frame,
      viewID: viewId,
      screenID: screenID,
      selectedIndex: selectedIndex,
      tabBarHeight: tabBarHeight,
      messenger: messenger
    )
  }
}

final class SwiftUIScreenPlatformView: NSObject, FlutterPlatformView {
  private let hostedView: UIView
  private let channel: FlutterMethodChannel
  private let financeTabBarModel: FinanceTabBarModel?

  init(
    frame: CGRect,
    viewID: Int64,
    screenID: String,
    selectedIndex: Int,
    tabBarHeight: Double,
    messenger: FlutterBinaryMessenger
  ) {
    channel = FlutterMethodChannel(
      name: "native-swiftui-view/\(viewID)",
      binaryMessenger: messenger
    )

    let tabBarModel = screenID == SwiftUIScreenID.financeTabBar.rawValue
      ? FinanceTabBarModel(selectedIndex: selectedIndex)
      : nil
    financeTabBarModel = tabBarModel

    let rootView = SwiftUIScreenPlatformView.makeRootView(
      for: screenID,
      financeTabBarModel: tabBarModel,
      channel: channel,
      tabBarHeight: tabBarHeight
    )

    let hostingController = UIHostingController(rootView: rootView)
    hostingController.view.frame = frame
    hostingController.view.backgroundColor = .clear
    hostedView = hostingController.view

    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "deallocated", message: nil, details: nil))
        return
      }

      switch call.method {
      case "setSelectedIndex":
        let arguments = call.arguments as? [String: Any]
        let index = arguments?["index"] as? Int ?? 0
        self.financeTabBarModel?.selectedIndex = index
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView {
    hostedView
  }

  private static func makeRootView(
    for screenID: String,
    financeTabBarModel: FinanceTabBarModel?,
    channel: FlutterMethodChannel,
    tabBarHeight: Double
  ) -> AnyView {
    guard let knownScreenID = SwiftUIScreenID(rawValue: screenID) else {
      return AnyView(UnsupportedSwiftUIScreenView(screenID: screenID))
    }

    return AnyView(
      SwiftUIScreenRegistry.makeScreen(
        for: knownScreenID,
        financeTabBarModel: financeTabBarModel,
        channel: channel,
        tabBarHeight: tabBarHeight
      )
    )
  }
}
