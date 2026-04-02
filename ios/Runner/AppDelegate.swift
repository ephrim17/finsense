import Flutter
import AppIntents
import UIKit
import WidgetKit

@available(iOS 16.0, *)
enum RunnerTransactionTypeIntent: String, AppEnum {
  case expense
  case income

  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transaction Type")
  static var caseDisplayRepresentations: [RunnerTransactionTypeIntent: DisplayRepresentation] = [
    .expense: DisplayRepresentation(title: "Expense"),
    .income: DisplayRepresentation(title: "Income")
  ]
}

@available(iOS 16.0, *)
struct RunnerCategoryOptionsProvider: DynamicOptionsProvider {
  func results() async throws -> [String] {
    [
      "Groceries",
      "Food & Dining",
      "Transport",
      "Shopping",
      "Bills & Utilities",
      "Rent",
      "Health",
      "Entertainment",
      "Travel",
      "Education",
      "Family",
      "Other Expense",
      "Salary",
      "Freelance",
      "Business",
      "Investment",
      "Rental Income",
      "Bonus",
      "Gift",
      "Refund",
      "Other Income"
    ]
  }
}

@available(iOS 16.0, *)
struct RunnerAddTransactionAppIntent: AppIntent {
  static var title: LocalizedStringResource = "Add Transaction"
  static var description = IntentDescription("Add an income or expense to FinSense.")
  static var openAppWhenRun: Bool = true

  @Parameter(title: "Title") var transactionTitle: String
  @Parameter(title: "Amount") var transactionAmount: Double
  @Parameter(title: "Type", default: .expense) var transactionType: RunnerTransactionTypeIntent
  @Parameter(title: "Category", optionsProvider: RunnerCategoryOptionsProvider()) var categoryName: String?

  func perform() async throws -> some IntentResult {
    let trimmedTitle = transactionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedCategory = categoryName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let normalizedTitle = trimmedTitle.isEmpty
      ? (trimmedCategory.isEmpty ? "Quick Entry" : trimmedCategory)
      : trimmedTitle

    let payload: [String: Any] = [
      "title": normalizedTitle,
      "amount": transactionAmount,
      "type": transactionType.rawValue,
      "categoryName": trimmedCategory,
      "paymentMethod": "Card",
      "accountId": "Main Account",
      "note": "",
      "transactionDate": ISO8601DateFormatter().string(from: Date())
    ]

    AppDelegate.storePendingTransaction(payload: payload)
    return .result()
  }
}

@available(iOS 16.0, *)
struct RunnerAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    return [
      AppShortcut(
        intent: RunnerAddTransactionAppIntent(),
        phrases: [
          "Add a transaction in \(.applicationName)",
          "Log an expense in \(.applicationName)",
          "Log income in \(.applicationName)"
        ],
        shortTitle: "Add Transaction",
        systemImageName: "plus.circle.fill"
      )
    ]
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let widgetChannelName = "com.finsense.widgets"
  private let appIntentChannelName = "com.finsense.app_intents"
  private let widgetAppGroupID = "group.com.example.finsense.shared"
  private let widgetSnapshotKey = "widget_snapshot_json"
  private let pendingTransactionIntentKey = "pending_app_intent_transaction_json"

  static let pendingTransactionIntentKey = "pending_app_intent_transaction_json"
  static let widgetAppGroupID = "group.com.example.finsense.shared"

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
      let appIntentChannel = FlutterMethodChannel(
        name: appIntentChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      appIntentChannel.setMethodCallHandler { [weak self] call, result in
        self?.handleAppIntentChannel(call: call, result: result)
      }
      controller.view.backgroundColor = .systemBackground
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if Self.storePendingTransaction(from: url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  static func storePendingTransaction(from url: URL) -> Bool {
    guard
      url.scheme?.lowercased() == "finsense",
      url.host?.lowercased() == "add-transaction",
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else {
      return false
    }

    var payload: [String: String] = [:]
    for item in components.queryItems ?? [] {
      payload[item.name] = item.value ?? ""
    }

    guard
      let title = payload["title"]?.trimmingCharacters(in: .whitespacesAndNewlines),
      !title.isEmpty,
      let amountText = payload["amount"],
      Double(amountText) ?? 0 > 0
    else {
      return false
    }

    let normalizedPayload: [String: Any] = [
      "title": title,
      "amount": Double(amountText) ?? 0,
      "type": payload["type"] ?? "expense",
      "categoryName": payload["categoryName"] ?? "",
      "paymentMethod": payload["paymentMethod"] ?? "Card",
      "accountId": payload["accountId"] ?? "Main Account",
      "note": payload["note"] ?? "",
      "transactionDate": payload["transactionDate"] ?? ISO8601DateFormatter().string(from: Date())
    ]

    return storePendingTransaction(payload: normalizedPayload)
  }

  static func storePendingTransaction(payload: [String: Any]) -> Bool {
    guard
      let data = try? JSONSerialization.data(withJSONObject: payload),
      let json = String(data: data, encoding: .utf8)
    else {
      return false
    }

    UserDefaults.standard.set(json, forKey: pendingTransactionIntentKey)
    UserDefaults.standard.synchronize()
    let sharedDefaults = UserDefaults(suiteName: widgetAppGroupID)
    sharedDefaults?.set(json, forKey: pendingTransactionIntentKey)
    sharedDefaults?.synchronize()
    return true
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

  private func handleAppIntentChannel(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let sharedDefaults = UserDefaults(suiteName: widgetAppGroupID)
    let standardDefaults = UserDefaults.standard

    switch call.method {
    case "consumePendingTransactionIntent":
      let json =
        standardDefaults.string(forKey: pendingTransactionIntentKey) ??
        sharedDefaults?.string(forKey: pendingTransactionIntentKey)
      standardDefaults.removeObject(forKey: pendingTransactionIntentKey)
      sharedDefaults?.removeObject(forKey: pendingTransactionIntentKey)
      result(json)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
