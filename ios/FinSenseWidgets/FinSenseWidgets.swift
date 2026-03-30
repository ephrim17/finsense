import SwiftUI
import WidgetKit

private enum FinSenseWidgetConstants {
  static let appGroupID = "group.com.example.finsense.shared"
  static let snapshotKey = "widget_snapshot_json"
  static let addExpenseURL = "finsense:///transactions/new?type=expense"
  static let transactionsURL = "finsense:///transactions"
}

private struct WidgetTransaction: Decodable, Identifiable {
  let id: String
  let title: String
  let categoryName: String
  let amount: Double
  let type: String
  let transactionDate: Date
}

private struct WidgetSnapshot: Decodable {
  let currencyCode: String
  let monthExpenseTotal: Double
  let recentTransactions: [WidgetTransaction]
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
          transactionDate: now
        ),
        WidgetTransaction(
          id: "2",
          title: "Salary",
          categoryName: "Salary",
          amount: 58000,
          type: "income",
          transactionDate: now
        ),
        WidgetTransaction(
          id: "3",
          title: "Cab",
          categoryName: "Transport",
          amount: 320,
          type: "expense",
          transactionDate: now
        ),
        WidgetTransaction(
          id: "4",
          title: "Coffee",
          categoryName: "Food & Dining",
          amount: 180,
          type: "expense",
          transactionDate: now
        ),
        WidgetTransaction(
          id: "5",
          title: "Books",
          categoryName: "Education",
          amount: 899,
          type: "expense",
          transactionDate: now
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
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
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
    decoder.dateDecodingStrategy = .iso8601

    return (try? decoder.decode(WidgetSnapshot.self, from: data))
      ?? PlaceholderFactory.makeSnapshot()
  }
}

private struct QuickAddExpenseWidgetView: View {
  let entry: FinSenseWidgetEntry

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [Color(red: 0.55, green: 0.36, blue: 0.96), Color(red: 0.49, green: 0.30, blue: 0.98)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 12) {
        HStack {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 20, weight: .semibold))
          Spacer()
          Text("Quick Add")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white.opacity(0.8))
        }

        Spacer()

        Text("Add Expense")
          .font(.system(size: 22, weight: .bold))
          .foregroundStyle(.white)

        Text("This month's spend")
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(.white.opacity(0.8))

        Text(currency(entry.snapshot.monthExpenseTotal, code: entry.snapshot.currencyCode))
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(.white)
      }
      .padding(16)
    }
    .widgetURL(URL(string: FinSenseWidgetConstants.addExpenseURL))
    .containerBackground(for: .widget) {
      Color.clear
    }
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
    Array(entry.snapshot.recentTransactions.prefix(5))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Last 5 Transactions")
            .font(.system(size: 16, weight: .bold))
          Text("Synced from FinSense")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: "arrow.up.right.square")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(Color(red: 0.55, green: 0.36, blue: 0.96))
      }

      if transactions.isEmpty {
        Spacer()
        Text("No transactions yet")
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(.secondary)
        Spacer()
      } else {
        ForEach(transactions) { transaction in
          RecentTransactionRow(
            transaction: transaction,
            amountText: amountText(for: transaction)
          )
        }
      }
    }
    .padding(16)
    .widgetURL(URL(string: FinSenseWidgetConstants.transactionsURL))
    .containerBackground(for: .widget) {
      LinearGradient(
        colors: [Color.white, Color(red: 0.98, green: 0.97, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
  }

  private func amountText(for transaction: WidgetTransaction) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = entry.snapshot.currencyCode
    formatter.maximumFractionDigits = 2
    formatter.locale = entry.snapshot.currencyCode == "INR" ? Locale(identifier: "en_IN") : .current
    let amount = formatter.string(from: NSNumber(value: transaction.amount)) ?? "\(transaction.amount)"
    return transaction.type == "expense" ? "-\(amount)" : amount
  }
}

private struct RecentTransactionRow: View {
  let transaction: WidgetTransaction
  let amountText: String

  private var isExpense: Bool {
    transaction.type == "expense"
  }

  private var iconName: String {
    isExpense ? "arrow.up.right" : "arrow.down.left"
  }

  private var iconTint: Color {
    isExpense ? .red : .green
  }

  private var iconBackground: Color {
    isExpense ? Color.red.opacity(0.12) : Color.green.opacity(0.12)
  }

  private var amountTint: Color {
    isExpense ? .primary : .green
  }

  var body: some View {
    HStack(spacing: 10) {
      Circle()
        .fill(iconBackground)
        .frame(width: 30, height: 30)
        .overlay(
          Image(systemName: iconName)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(iconTint)
        )

      VStack(alignment: .leading, spacing: 2) {
        Text(transaction.title)
          .font(.system(size: 13, weight: .semibold))
          .lineLimit(1)
        Text(transaction.categoryName)
          .font(.system(size: 11, weight: .medium))
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }

      Spacer()

      Text(amountText)
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(amountTint)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
  }
}

struct QuickAddExpenseWidget: Widget {
  let kind = "QuickAddExpenseWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FinSenseWidgetProvider()) { entry in
      QuickAddExpenseWidgetView(entry: entry)
    }
    .configurationDisplayName("Quick Add Expense")
    .description("Open FinSense and jump straight into the expense entry flow.")
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
    .description("See the latest five transactions from your finance tracker.")
    .supportedFamilies([.systemMedium])
  }
}

@main
struct FinSenseWidgetsBundle: WidgetBundle {
  var body: some Widget {
    QuickAddExpenseWidget()
    RecentTransactionsWidget()
  }
}
