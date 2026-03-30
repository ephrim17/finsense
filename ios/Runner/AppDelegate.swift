import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let widgetChannelName = "com.finsense.widgets"
  private let widgetAppGroupID = "group.com.example.finsense.shared"
  private let widgetSnapshotKey = "widget_snapshot_json"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      if let registrar = registrar(forPlugin: "native-swiftui-view") {
        let factory = SwiftUIScreenFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "native-swiftui-view")
      }
      let widgetChannel = FlutterMethodChannel(
        name: widgetChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      widgetChannel.setMethodCallHandler { [weak self] call, result in
        self?.handleWidgetChannel(call: call, result: result)
      }
      controller.view.backgroundColor = .systemBackground
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleWidgetChannel(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let defaults = UserDefaults(suiteName: widgetAppGroupID)

    switch call.method {
    case "updateWidgetSnapshot":
      let arguments = call.arguments as? [String: Any]
      let json = arguments?["json"] as? String
      defaults?.set(json, forKey: widgetSnapshotKey)
      WidgetCenter.shared.reloadAllTimelines()
      result(nil)
    case "clearWidgetSnapshot":
      defaults?.removeObject(forKey: widgetSnapshotKey)
      WidgetCenter.shared.reloadAllTimelines()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
