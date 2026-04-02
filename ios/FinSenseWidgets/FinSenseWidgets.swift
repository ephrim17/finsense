import SwiftUI
import WidgetKit
import AppIntents
import Foundation

private enum FinSenseWidgetConstants {
  static let appGroupID = "group.com.example.finsense.shared"
  static let snapshotKey = "widget_snapshot_json"
  static let pendingTransactionIntentKey = "pending_app_intent_transaction_json"
  static let addExpenseURL = "finsense:///transactions/new?type=expense"
  static let transactionsURL = "finsense:///transactions"
  static let budgetsURL = "finsense:///budgets"
}

private enum FinSenseWidgetPalette {
  static let primaryPurple = Color(red: 0.55, green: 0.36, blue: 0.96)
  static let deepPurple = Color(red: 0.46, green: 0.27, blue: 0.95)
  static let lightLavender = Color(red: 0.96, green: 0.94, blue: 1.0)
  static let cardWhite = Color.white
  static let textPrimary = Color(red: 0.13, green: 0.11, blue: 0.22)
  static let textSecondary = Color(red: 0.47, green: 0.44, blue: 0.56)
  static let expenseTint = Color(red: 0.95, green: 0.34, blue: 0.42)
  static let incomeTint = Color(red: 0.13, green: 0.77, blue: 0.45)
  static let warningTint = Color(red: 0.98, green: 0.66, blue: 0.18)
  static let dangerTint = Color(red: 0.95, green: 0.36, blue: 0.42)
}

private struct WidgetTransaction: Decodable, Identifiable {
  let id: String
  let title: String
  let categoryName: String
  let amount: Double
  let type: String
  let paymentMethod: String
  let accountId: String?
  let note: String?
  let transactionDate: Date
}

private struct WidgetBudgetHighlight: Decodable, Identifiable {
  let id: String
  let categoryName: String
  let limitAmount: Double
  let spentAmount: Double
  let remainingAmount: Double
  let progress: Double
  let health: String
}

private struct WidgetSnapshot: Decodable {
  let currencyCode: String
  let monthExpenseTotal: Double
  let recentTransactions: [WidgetTransaction]
  let budgetHighlights: [WidgetBudgetHighlight]
  let updatedAt: Date
}

private struct FinSenseWidgetEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

private struct PlaceholderFactory {
  static func makeSnapshot() -> WidgetSnapshot {
    let now = Date()
    return WidgetSnapshot(
      currencyCode: "INR",
      monthExpenseTotal: 24580,
      recentTransactions: [
        WidgetTransaction(
          id: "1",
          title: "Groceries",
          categoryName: "Food & Dining",
          amount: 1250,
          type: "expense",
          paymentMethod: "UPI",
          accountId: "Main Account",
          note: nil,
          transactionDate: now
        ),
        WidgetTransaction(
          id: "2",
          title: "Salary",
          categoryName: "Salary",
          amount: 58000,
          type: "income",
          paymentMethod: "Bank Transfer",
          accountId: "Main Account",
          note: nil,
          transactionDate: now
        ),
        WidgetTransaction(
          id: "3",
          title: "Cab",
          categoryName: "Transport",
          amount: 320,
          type: "expense",
          paymentMethod: "Card",
          accountId: "Main Account",
          note: nil,
          transactionDate: now
        ),
        WidgetTransaction(
          id: "4",
          title: "Coffee",
          categoryName: "Food & Dining",
          amount: 180,
          type: "expense",
          paymentMethod: "Cash",
          accountId: "Main Account",
          note: nil,
          transactionDate: now
        ),
        WidgetTransaction(
          id: "5",
          title: "Books",
          categoryName: "Education",
          amount: 899,
          type: "expense",
          paymentMethod: "Card",
          accountId: "Main Account",
          note: nil,
          transactionDate: now
        )
      ],
      budgetHighlights: [
        WidgetBudgetHighlight(
          id: "b1",
          categoryName: "Food & Dining",
          limitAmount: 12000,
          spentAmount: 10500,
          remainingAmount: 1500,
          progress: 0.875,
          health: "warning"
        ),
        WidgetBudgetHighlight(
          id: "b2",
          categoryName: "Transport",
          limitAmount: 6000,
          spentAmount: 6400,
          remainingAmount: -400,
          progress: 1,
          health: "overLimit"
        )
      ],
      updatedAt: now
    )
  }
}

private struct FinSenseWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> FinSenseWidgetEntry {
    FinSenseWidgetEntry(date: Date(), snapshot: PlaceholderFactory.makeSnapshot())
  }

  func getSnapshot(in context: Context, completion: @escaping (FinSenseWidgetEntry) -> Void) {
    completion(FinSenseWidgetEntry(date: Date(), snapshot: loadSnapshot()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<FinSenseWidgetEntry>) -> Void) {
    let entry = FinSenseWidgetEntry(date: Date(), snapshot: loadSnapshot())
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }

  private func loadSnapshot() -> WidgetSnapshot {
    let defaults = UserDefaults(suiteName: FinSenseWidgetConstants.appGroupID)
    guard
      let json = defaults?.string(forKey: FinSenseWidgetConstants.snapshotKey),
      let data = json.data(using: .utf8)
    else {
      return PlaceholderFactory.makeSnapshot()
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let value = try container.decode(String.self)

      let parser = ISO8601DateFormatter()
      parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      let fallback = ISO8601DateFormatter()

      if let date = parser.date(from: value) ?? fallback.date(from: value) {
        return date
      }
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid ISO8601 date: \(value)"
      )
    }

    return (try? decoder.decode(WidgetSnapshot.self, from: data))
      ?? PlaceholderFactory.makeSnapshot()
  }
}

private enum FinSenseSnapshotStore {
  static func loadSnapshot() -> WidgetSnapshot? {
    let defaults = UserDefaults(suiteName: FinSenseWidgetConstants.appGroupID)
    guard
      let json = defaults?.string(forKey: FinSenseWidgetConstants.snapshotKey),
      let data = json.data(using: .utf8)
    else {
      return nil
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let value = try container.decode(String.self)

      let parser = ISO8601DateFormatter()
      parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      let fallback = ISO8601DateFormatter()

      if let date = parser.date(from: value) ?? fallback.date(from: value) {
        return date
      }
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid ISO8601 date: \(value)"
      )
    }

    return try? decoder.decode(WidgetSnapshot.self, from: data)
  }

  static func savePendingTransaction(_ payload: [String: Any]) {
    guard
      let data = try? JSONSerialization.data(withJSONObject: payload),
      let json = String(data: data, encoding: .utf8)
    else {
      return
    }
    let sharedDefaults = UserDefaults(suiteName: FinSenseWidgetConstants.appGroupID)
    sharedDefaults?.set(json, forKey: FinSenseWidgetConstants.pendingTransactionIntentKey)
    sharedDefaults?.synchronize()
  }

  static func currency(_ amount: Double, code: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = code
    formatter.maximumFractionDigits = 2
    formatter.locale = code == "INR" ? Locale(identifier: "en_IN") : .current
    return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
  }

  static func dateLabel(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_IN")
    formatter.dateFormat = "EEE, d MMM yyyy"
    return formatter.string(from: date)
  }

  static func matchingTransaction(category: String?) -> WidgetTransaction? {
    let transactions = loadSnapshot()?.recentTransactions ?? []
    guard let category, !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return transactions.first
    }

    let normalizedFilter = normalizedText(category)
    return transactions.first {
      normalizedText($0.categoryName).contains(normalizedFilter) ||
      normalizedFilter.contains(normalizedText($0.categoryName))
    }
  }

  static func recentTransactions(category: String?, limit: Int) -> [WidgetTransaction] {
    let transactions = loadSnapshot()?.recentTransactions ?? []
    guard let category, !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return Array(transactions.prefix(limit))
    }

    let normalizedFilter = normalizedText(category)
    return Array(
      transactions.filter {
        normalizedText($0.categoryName).contains(normalizedFilter) ||
        normalizedFilter.contains(normalizedText($0.categoryName))
      }
      .prefix(limit)
    )
  }

  private static func normalizedText(_ value: String) -> String {
    value
      .lowercased()
      .replacingOccurrences(of: "dinning", with: "dining")
      .components(separatedBy: CharacterSet.alphanumerics.inverted)
      .filter { !$0.isEmpty }
      .joined(separator: " ")
  }
}

@available(iOS 16.0, *)
enum FinSenseTransactionTypeIntent: String, AppEnum {
  case expense
  case income

  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transaction Type")
  static var caseDisplayRepresentations: [FinSenseTransactionTypeIntent: DisplayRepresentation] = [
    .expense: DisplayRepresentation(title: "Expense"),
    .income: DisplayRepresentation(title: "Income")
  ]
}

@available(iOS 16.0, *)
struct FinSenseCategoryOptionsProvider: DynamicOptionsProvider {
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
struct LatestTransactionDetailsAppIntent: AppIntent {
  static var title: LocalizedStringResource = "Latest Transaction Details"
  static var description = IntentDescription("Look up the latest FinSense transaction, optionally filtered by category.")

  @Parameter(title: "Category", optionsProvider: FinSenseCategoryOptionsProvider()) var categoryName: String?

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let selectedCategory = categoryName?.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let snapshot = FinSenseSnapshotStore.loadSnapshot() else {
      let message = "Open FinSense once so I can sync your transactions."
      return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }

    guard let transaction = FinSenseSnapshotStore.matchingTransaction(category: selectedCategory) else {
      if let selectedCategory, !selectedCategory.isEmpty {
        let message = "I couldn’t find a recent \(selectedCategory) transaction in FinSense."
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
      }
      let message = "I couldn’t find any recent transactions in FinSense."
      return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }

    let amount = FinSenseSnapshotStore.currency(transaction.amount, code: snapshot.currencyCode)
    let date = FinSenseSnapshotStore.dateLabel(transaction.transactionDate)
    let detail = "\(transaction.title) in \(transaction.categoryName) on \(date) for \(amount) via \(transaction.paymentMethod)."
    return .result(value: detail, dialog: IntentDialog(stringLiteral: detail))
  }
}

@available(iOS 16.0, *)
struct RecentTransactionsAppIntent: AppIntent {
  static var title: LocalizedStringResource = "Recent Transactions"
  static var description = IntentDescription("Get a quick summary of your recent FinSense transactions.")

  @Parameter(title: "Category", optionsProvider: FinSenseCategoryOptionsProvider()) var categoryName: String?
  @Parameter(title: "Limit", default: 3) var limit: Int

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let selectedCategory = categoryName?.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let snapshot = FinSenseSnapshotStore.loadSnapshot() else {
      let message = "Open FinSense once so I can sync your transactions."
      return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }

    let transactions = FinSenseSnapshotStore.recentTransactions(
      category: selectedCategory,
      limit: max(1, min(limit, 5))
    )

    guard !transactions.isEmpty else {
      if let selectedCategory, !selectedCategory.isEmpty {
        let message = "I couldn’t find recent \(selectedCategory) transactions in FinSense."
        return .result(value: message, dialog: IntentDialog(stringLiteral: message))
      }
      let message = "I couldn’t find any recent transactions in FinSense."
      return .result(value: message, dialog: IntentDialog(stringLiteral: message))
    }

    let summary = transactions.map { transaction in
      let amount = FinSenseSnapshotStore.currency(transaction.amount, code: snapshot.currencyCode)
      let date = FinSenseSnapshotStore.dateLabel(transaction.transactionDate)
      return "\(transaction.title) on \(date) for \(amount)"
    }
    .joined(separator: ", ")

    return .result(value: summary, dialog: IntentDialog(stringLiteral: summary))
  }
}

@available(iOS 16.0, *)
struct FinSenseAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    return [
      AppShortcut(
        intent: LatestTransactionDetailsAppIntent(),
        phrases: [
          "What was my latest transaction in \(.applicationName)",
          "Show my last grocery transaction in \(.applicationName)"
        ],
        shortTitle: "Latest Transaction",
        systemImageName: "text.magnifyingglass"
      ),
      AppShortcut(
        intent: RecentTransactionsAppIntent(),
        phrases: [
          "Show recent transactions in \(.applicationName)",
          "What did I spend recently in \(.applicationName)"
        ],
        shortTitle: "Recent Transactions",
        systemImageName: "list.bullet.rectangle"
      )
    ]
  }
}

private struct QuickAddExpenseWidgetView: View {
  let entry: FinSenseWidgetEntry

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottomLeading) {
        LinearGradient(
          colors: [FinSenseWidgetPalette.primaryPurple, FinSenseWidgetPalette.deepPurple],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )

        Circle()
          .fill(Color.white.opacity(0.12))
          .frame(width: geometry.size.width * 0.82, height: geometry.size.width * 0.82)
          .offset(x: geometry.size.width * 0.36, y: geometry.size.height * 0.28)

        Circle()
          .fill(Color.black.opacity(0.08))
          .frame(width: geometry.size.width * 0.62, height: geometry.size.width * 0.62)
          .offset(x: geometry.size.width * 0.58, y: -geometry.size.height * 0.36)

        VStack(alignment: .leading, spacing: 0) {
          HStack {
            ZStack {
              Circle()
                .fill(Color.black.opacity(0.9))
              Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            Spacer()

            Text("Quick Add")
              .font(.system(size: 13, weight: .semibold, design: .rounded))
              .foregroundStyle(.white.opacity(0.94))
              .lineLimit(1)
          }

          Spacer()

          Text("Add Expense")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(2)
            .minimumScaleFactor(0.78)

          Text("Monthly spend")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white.opacity(0.78))
            .padding(.top, 6)

          Text(currency(entry.snapshot.monthExpenseTotal, code: entry.snapshot.currencyCode))
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.top, 10)
        }
        .padding(16)
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
    .widgetURL(URL(string: FinSenseWidgetConstants.addExpenseURL))
  }

  private func currency(_ amount: Double, code: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = code
    formatter.maximumFractionDigits = 2
    formatter.locale = code == "INR" ? Locale(identifier: "en_IN") : .current
    return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
  }
}

private struct RecentTransactionsWidgetView: View {
  let entry: FinSenseWidgetEntry

  private var transactions: [WidgetTransaction] {
    Array(entry.snapshot.recentTransactions.prefix(3))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Recent")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(FinSenseWidgetPalette.textPrimary)
          Text(updatedLabel)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(FinSenseWidgetPalette.textSecondary)
        }

        Spacer()

        Text(totalMovementLabel)
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(FinSenseWidgetPalette.primaryPurple)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(FinSenseWidgetPalette.primaryPurple.opacity(0.1))
          .clipShape(Capsule())
      }

      if transactions.isEmpty {
        Spacer()
        Text("Recent transactions will appear here after sync.")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(FinSenseWidgetPalette.textSecondary)
        Spacer()
      } else {
        VStack(spacing: 10) {
          ForEach(transactions) { transaction in
            RecentTransactionRow(
              transaction: transaction,
              currencyCode: entry.snapshot.currencyCode
            )
          }
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(
      LinearGradient(
        colors: [FinSenseWidgetPalette.cardWhite, FinSenseWidgetPalette.lightLavender],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    .widgetURL(URL(string: FinSenseWidgetConstants.transactionsURL))
  }

  private var updatedLabel: String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_IN")
    formatter.dateFormat = "d MMM"
    return "Snapshot • \(formatter.string(from: entry.snapshot.updatedAt))"
  }

  private var totalMovementLabel: String {
    "\(transactions.count) items"
  }
}

private struct RecentTransactionRow: View {
  let transaction: WidgetTransaction
  let currencyCode: String

  private var isExpense: Bool {
    transaction.type == "expense"
  }

  private var amountText: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode
    formatter.maximumFractionDigits = 2
    formatter.locale = currencyCode == "INR" ? Locale(identifier: "en_IN") : .current
    let amount = formatter.string(from: NSNumber(value: transaction.amount)) ?? "\(transaction.amount)"
    return isExpense ? "-\(amount)" : "+\(amount)"
  }

  private var amountTint: Color {
    isExpense ? FinSenseWidgetPalette.textPrimary : FinSenseWidgetPalette.incomeTint
  }

  private var iconTint: Color {
    isExpense ? FinSenseWidgetPalette.expenseTint : FinSenseWidgetPalette.incomeTint
  }

  private var iconBackground: Color {
    isExpense
      ? FinSenseWidgetPalette.expenseTint.opacity(0.14)
      : FinSenseWidgetPalette.incomeTint.opacity(0.14)
  }

  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(iconBackground)
        Image(systemName: isExpense ? "arrow.up.right" : "arrow.down.left")
          .font(.system(size: 12, weight: .bold))
          .foregroundStyle(iconTint)
      }
      .frame(width: 40, height: 40)

      VStack(alignment: .leading, spacing: 3) {
        Text(transaction.title)
          .font(.system(size: 14, weight: .bold, design: .rounded))
          .foregroundStyle(FinSenseWidgetPalette.textPrimary)
          .lineLimit(1)
        Text("\(transaction.categoryName) • \(shortPaymentMethod)")
          .font(.system(size: 11, weight: .medium))
          .foregroundStyle(FinSenseWidgetPalette.textSecondary)
          .lineLimit(1)
        Text(formattedDay(transaction.transactionDate))
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(FinSenseWidgetPalette.textSecondary.opacity(0.82))
      }

      Spacer(minLength: 8)

      Text(amountText)
        .font(.system(size: 14, weight: .bold, design: .rounded))
        .foregroundStyle(amountTint)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
    .padding(.vertical, 2)
  }

  private var shortPaymentMethod: String {
    transaction.paymentMethod.count > 12
      ? String(transaction.paymentMethod.prefix(10)) + "…"
      : transaction.paymentMethod
  }

  private func formattedDay(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_IN")
    formatter.dateFormat = "d MMM"
    return formatter.string(from: date)
  }
}

private struct BudgetLimitWidgetView: View {
  let entry: FinSenseWidgetEntry

  private var highlights: [WidgetBudgetHighlight] {
    Array(entry.snapshot.budgetHighlights.prefix(2))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 2) {
          Text("Budget Watch")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(FinSenseWidgetPalette.textPrimary)
          Text("Near limit")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(FinSenseWidgetPalette.textSecondary)
        }
        Spacer()
        if let primary = highlights.first {
          Text(primary.health == "overLimit" ? "Alert" : "Warning")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(primary.health == "overLimit" ? FinSenseWidgetPalette.dangerTint : FinSenseWidgetPalette.warningTint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background((primary.health == "overLimit" ? FinSenseWidgetPalette.dangerTint : FinSenseWidgetPalette.warningTint).opacity(0.12))
            .clipShape(Capsule())
        }
      }

      if highlights.isEmpty {
        Spacer()
        Text("All tracked budgets are healthy right now.")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(FinSenseWidgetPalette.textSecondary)
        Spacer()
      } else {
        VStack(spacing: 10) {
          ForEach(highlights) { budget in
            BudgetLimitRow(budget: budget, currencyCode: entry.snapshot.currencyCode)
          }
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(
      LinearGradient(
        colors: [FinSenseWidgetPalette.cardWhite, FinSenseWidgetPalette.lightLavender],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    .widgetURL(URL(string: FinSenseWidgetConstants.budgetsURL))
  }
}

private struct BudgetLimitRow: View {
  let budget: WidgetBudgetHighlight
  let currencyCode: String

  private var tint: Color {
    budget.health == "overLimit"
      ? FinSenseWidgetPalette.dangerTint
      : FinSenseWidgetPalette.warningTint
  }

  private var statusText: String {
    if budget.health == "overLimit" {
      return "Over by \(currency(abs(budget.remainingAmount)))"
    }
    return "\(Int((budget.progress * 100).rounded()))% used • \(currency(max(0, budget.remainingAmount))) left"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(budget.categoryName)
          .font(.system(size: 14, weight: .bold, design: .rounded))
          .foregroundStyle(FinSenseWidgetPalette.textPrimary)
          .lineLimit(1)
        Spacer()
        Text(statusText)
          .font(.system(size: 10, weight: .bold))
          .foregroundStyle(tint)
          .lineLimit(1)
          .minimumScaleFactor(0.72)
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(FinSenseWidgetPalette.lightLavender)
          Capsule()
            .fill(
              LinearGradient(
                colors: [tint.opacity(0.85), tint],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .frame(width: geometry.size.width * min(max(budget.progress, 0), 1))
        }
      }
      .frame(height: 8)

      Text("\(currency(budget.spentAmount)) of \(currency(budget.limitAmount))")
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(FinSenseWidgetPalette.textSecondary)
        .lineLimit(1)
    }
  }

  private func currency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currencyCode
    formatter.maximumFractionDigits = 2
    formatter.locale = currencyCode == "INR" ? Locale(identifier: "en_IN") : .current
    return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
  }
}

struct QuickAddExpenseWidget: Widget {
  let kind = "QuickAddExpenseWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FinSenseWidgetProvider()) { entry in
      QuickAddExpenseWidgetView(entry: entry)
    }
    .configurationDisplayName("Quick Add Expense")
    .description("Open FinSense and jump straight into expense entry.")
    .supportedFamilies([.systemSmall])
  }
}

struct RecentTransactionsWidget: Widget {
  let kind = "RecentTransactionsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FinSenseWidgetProvider()) { entry in
      RecentTransactionsWidgetView(entry: entry)
    }
    .configurationDisplayName("Recent Transactions")
    .description("See a clean live snapshot of your latest money movement.")
    .supportedFamilies([.systemMedium])
  }
}

struct BudgetLimitWidget: Widget {
  let kind = "BudgetLimitWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FinSenseWidgetProvider()) { entry in
      BudgetLimitWidgetView(entry: entry)
    }
    .configurationDisplayName("Budget Watch")
    .description("Monitor categories that are nearing or over their monthly limit.")
    .supportedFamilies([.systemMedium])
  }
}

@main
struct FinSenseWidgetsBundle: WidgetBundle {
  var body: some Widget {
    QuickAddExpenseWidget()
    RecentTransactionsWidget()
    BudgetLimitWidget()
  }
}
