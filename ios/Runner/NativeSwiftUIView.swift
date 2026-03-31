import Flutter
import Foundation
import SwiftUI
import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

struct NativeCommandDeckView: View {
  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.05, green: 0.09, blue: 0.18),
          Color(red: 0.04, green: 0.21, blue: 0.33),
          Color(red: 0.02, green: 0.47, blue: 0.56),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 20) {
        Text("Native surfaces for Flutter, designed to scale.")
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
          .multilineTextAlignment(.center)

        Button(action: {}) {
          HStack(spacing: 10) {
            Image(systemName: "sparkles")
            Text("Button check")
              .fontWeight(.semibold)
          }
          .font(.footnote)
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(
            LinearGradient(
              colors: [.cyan, .blue],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .foregroundStyle(.white)
          .clipShape(Capsule())
          .shadow(color: Color.cyan.opacity(0.35), radius: 18, x: 0, y: 10)
        }
      }
      .padding(24)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .background(
        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(Color.white.opacity(0.08))
          .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
              .stroke(Color.cyan.opacity(0.35), lineWidth: 1)
          )
          .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 16)
      )
      .padding(20)
    }
  }
}

final class FinanceTabBarModel: ObservableObject {
  @Published var selectedIndex: Int

  init(selectedIndex: Int) {
    self.selectedIndex = selectedIndex
  }
}

private struct FinanceTabBarItem: Identifiable {
  let id: Int
  let title: String
  let icon: String
}

struct FinanceTabBarView: View {
  @ObservedObject var model: FinanceTabBarModel
  let tabBarHeight: Double
  let onTabSelected: (Int) -> Void

  var body: some View {
    NativeUIKitTabBarRepresentable(
      selectedIndex: $model.selectedIndex,
      onTabSelected: onTabSelected
    )
    .frame(height: tabBarHeight)
    .background(Color.clear)
  }
}

struct NativeUIKitTabBarRepresentable: UIViewRepresentable {
  @Binding var selectedIndex: Int
  let onTabSelected: (Int) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(selectedIndex: $selectedIndex, onTabSelected: onTabSelected)
  }

  func makeUIView(context: Context) -> UITabBar {
    let tabBar = UITabBar(frame: .zero)
    tabBar.delegate = context.coordinator
    tabBar.isTranslucent = true
    tabBar.tintColor = UIColor.systemPurple
    tabBar.unselectedItemTintColor = UIColor.secondaryLabel

    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    tabBar.standardAppearance = appearance

    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = appearance
    }

    tabBar.items = [
      UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill")),
      UITabBarItem(title: "Transactions", image: UIImage(systemName: "list.bullet.rectangle"), selectedImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill")),
      UITabBarItem(title: "Budgets", image: UIImage(systemName: "wallet.bifold"), selectedImage: UIImage(systemName: "wallet.bifold.fill")),
      UITabBarItem(title: "Goals", image: UIImage(systemName: "flag"), selectedImage: UIImage(systemName: "flag.fill")),
      UITabBarItem(title: "Reports", image: UIImage(systemName: "chart.pie"), selectedImage: UIImage(systemName: "chart.pie.fill"))
    ]
    tabBar.selectedItem = tabBar.items?[safe: selectedIndex]
    return tabBar
  }

  func updateUIView(_ uiView: UITabBar, context: Context) {
    uiView.selectedItem = uiView.items?[safe: selectedIndex]
  }

  final class Coordinator: NSObject, UITabBarDelegate {
    @Binding private var selectedIndex: Int
    private let onTabSelected: (Int) -> Void

    init(selectedIndex: Binding<Int>, onTabSelected: @escaping (Int) -> Void) {
      _selectedIndex = selectedIndex
      self.onTabSelected = onTabSelected
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
      guard let items = tabBar.items, let index = items.firstIndex(of: item) else {
        return
      }
      selectedIndex = index
      onTabSelected(index)
    }
  }
}

private extension Collection {
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

struct UnsupportedSwiftUIScreenView: View {
  let screenID: String

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      VStack(spacing: 12) {
        Image(systemName: "exclamationmark.triangle")
          .font(.largeTitle)
          .foregroundStyle(.yellow)
        Text("Unknown SwiftUI Screen")
          .font(.headline)
          .foregroundStyle(.white)
        Text(screenID)
          .font(.footnote.monospaced())
          .foregroundStyle(.white.opacity(0.7))
      }
      .padding(24)
    }
  }
}

private struct AIInsightsSnapshot: Decodable {
  struct Summary: Decodable {
    let balance: Double
    let income: Double
    let expenses: Double
    let savings: Double
    let budgetUsed: Double
  }

  struct Budget: Decodable, Identifiable {
    let id = UUID()
    let categoryName: String
    let limitAmount: Double
    let spentAmount: Double
    let remainingAmount: Double
    let progress: Double
    let health: String
  }

  struct Goal: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let targetAmount: Double
    let currentAmount: Double
    let progress: Double
    let status: String
    let deadline: String?
  }

  struct Transaction: Decodable, Identifiable {
    let id: String
    let title: String
    let categoryName: String
    let amount: Double
    let type: String
    let paymentMethod: String
    let transactionDate: String
  }

  struct Signals: Decodable {
    struct ExpenseSignal: Decodable, Identifiable {
      let id: String
      let title: String
      let categoryName: String
      let amount: Double
      let paymentMethod: String
      let transactionDate: String
    }

    let averageExpense: Double?
    let largestExpense: ExpenseSignal?
    let transactionAnomalies: [ExpenseSignal]
    let overspendingHighlights: [Budget]
    let suggestedGoalTopUp: Double?
  }

  let summary: Summary?
  let quickInsight: String?
  let signals: Signals?
  let budgets: [Budget]
  let goals: [Goal]
  let recentTransactions: [Transaction]

  static let empty = AIInsightsSnapshot(
    summary: nil,
    quickInsight: nil,
    signals: nil,
    budgets: [],
    goals: [],
    recentTransactions: []
  )
}

private struct AIChatMessage: Identifiable {
  let id = UUID()
  let role: Role
  var text: String
  var transactions: [AIInsightsSnapshot.Transaction] = []

  enum Role {
    case assistant
    case user
  }
}

private struct AIInsightCardModel: Identifiable {
  let id = UUID()
  let title: String
  let value: String
  let caption: String
  let icon: String
  let tint: Color
}

private struct AITransactionListResponse {
  let text: String
  let transactions: [AIInsightsSnapshot.Transaction]
}

struct AIInsightsChatHostView: View {
  let snapshotJSON: String
  let onClose: () -> Void
  let onOpenTransaction: (String) -> Void

  var body: some View {
    AIInsightsChatView(
      snapshot: decodeSnapshot(),
      onClose: onClose,
      onOpenTransaction: onOpenTransaction
    )
  }

  private func decodeSnapshot() -> AIInsightsSnapshot {
    guard let data = snapshotJSON.data(using: .utf8) else {
      return .empty
    }
    let decoder = JSONDecoder()
    return (try? decoder.decode(AIInsightsSnapshot.self, from: data)) ?? .empty
  }
}

private struct AIInsightsChatView: View {
  @StateObject private var model: AIInsightsChatViewModel
  let onClose: () -> Void
  let onOpenTransaction: (String) -> Void

  init(
    snapshot: AIInsightsSnapshot,
    onClose: @escaping () -> Void,
    onOpenTransaction: @escaping (String) -> Void
  ) {
    self.onClose = onClose
    self.onOpenTransaction = onOpenTransaction
    _model = StateObject(wrappedValue: AIInsightsChatViewModel(snapshot: snapshot))
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.07, green: 0.05, blue: 0.14),
          Color(red: 0.17, green: 0.10, blue: 0.30),
          Color(red: 0.31, green: 0.19, blue: 0.56)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 0) {
        HStack(alignment: .top) {
          Button(action: onClose) {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .bold))
              .foregroundStyle(.white)
              .frame(width: 42, height: 42)
              .background(Color.white.opacity(0.12))
              .clipShape(Circle())
          }

          VStack(alignment: .leading, spacing: 6) {
            Text("FinSense AI")
              .font(.system(size: 30, weight: .bold, design: .rounded))
              .foregroundStyle(.white)
            Text("Quick budgeting and spending insights from your current data.")
              .font(.system(size: 15, weight: .medium))
              .foregroundStyle(.white.opacity(0.78))
          }
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)

        if !model.insightCards.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              ForEach(model.insightCards) { card in
                _AIInsightCard(card: card)
              }
            }
            .padding(.horizontal, 20)
          }
          .padding(.bottom, 16)
        }

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(model.starterPrompts, id: \.self) { prompt in
              Button {
                model.send(prompt: prompt)
              } label: {
                Text(prompt)
                  .font(.system(size: 13, weight: .semibold))
                  .padding(.horizontal, 14)
                  .padding(.vertical, 10)
                  .background(Color.white.opacity(0.14))
                  .foregroundStyle(.white)
                  .clipShape(Capsule())
              }
            }
          }
          .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(model.statementFilterPrompts, id: \.self) { prompt in
              Button {
                model.send(prompt: prompt)
              } label: {
                Text(prompt)
                  .font(.system(size: 12, weight: .semibold))
                  .padding(.horizontal, 14)
                  .padding(.vertical, 9)
                  .background(Color.white.opacity(0.1))
                  .foregroundStyle(.white.opacity(0.92))
                  .clipShape(Capsule())
              }
            }
          }
          .padding(.horizontal, 20)
        }
        .padding(.bottom, 14)

        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(spacing: 12) {
              ForEach(model.messages) { message in
                HStack {
                  if message.role == .assistant {
                    _AssistantBubble(
                      text: message.text,
                      transactions: message.transactions,
                      onOpenTransaction: onOpenTransaction
                    )
                    Spacer(minLength: 44)
                  } else {
                    Spacer(minLength: 44)
                    _UserBubble(text: message.text)
                  }
                }
                .id(message.id)
              }

              if model.isLoading {
                HStack {
                  _TypingBubble()
                  Spacer(minLength: 44)
                }
              }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
          }
          .onChange(of: model.messages.count) { _, _ in
            if let lastID = model.messages.last?.id {
              withAnimation {
                proxy.scrollTo(lastID, anchor: .bottom)
              }
            }
          }
        }

        VStack(spacing: 10) {
          if !model.followUpPrompts.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 10) {
                ForEach(model.followUpPrompts, id: \.self) { prompt in
                  Button {
                    model.send(prompt: prompt)
                  } label: {
                    HStack(spacing: 6) {
                      Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                      Text(prompt)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.88))
                    .foregroundStyle(Color(red: 0.22, green: 0.12, blue: 0.38))
                    .clipShape(Capsule())
                  }
                }
              }
              .padding(.horizontal, 20)
              .padding(.top, 4)
            }
          }

          HStack(spacing: 12) {
            TextField("Ask about budgets, spending, goals...", text: $model.draft, axis: .vertical)
              .textFieldStyle(.plain)
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.white)
              .padding(.horizontal, 16)
              .padding(.vertical, 14)
              .background(Color.white.opacity(0.12))
              .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Button {
              model.send(prompt: model.draft)
            } label: {
              Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .bold))
                .frame(width: 52, height: 52)
                .background(
                  LinearGradient(
                    colors: [Color.white, Color(red: 0.93, green: 0.86, blue: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
                .foregroundStyle(Color(red: 0.31, green: 0.19, blue: 0.56))
                .clipShape(Circle())
            }
            .disabled(model.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.isLoading)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 18)
        }
        .padding(.top, 10)
        .background(Color.black.opacity(0.16))
      }
    }
  }
}

private struct _AIInsightCard: View {
  let card: AIInsightCardModel

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Image(systemName: card.icon)
          .font(.system(size: 15, weight: .bold))
          .foregroundStyle(card.tint)
        Spacer()
      }

      Text(card.title)
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(.white.opacity(0.72))

      Text(card.value)
        .font(.system(size: 21, weight: .bold, design: .rounded))
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.8)

      Text(card.caption)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.white.opacity(0.72))
        .lineLimit(2)
    }
    .padding(16)
    .frame(width: 178, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(Color.white.opacity(0.12))
        .overlay(
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    )
  }
}

private struct _AssistantBubble: View {
  let text: String
  let transactions: [AIInsightsSnapshot.Transaction]
  let onOpenTransaction: (String) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: transactions.isEmpty ? 0 : 12) {
      Text(text)
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(Color(red: 0.16, green: 0.10, blue: 0.28))

      if !transactions.isEmpty {
        VStack(spacing: 10) {
          ForEach(transactions) { transaction in
            Button {
              onOpenTransaction(transaction.id)
            } label: {
              _RecentTransactionCard(transaction: transaction)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
  }
}

private struct _RecentTransactionCard: View {
  let transaction: AIInsightsSnapshot.Transaction

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      VStack(alignment: .leading, spacing: 5) {
        Text(transaction.title)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(Color(red: 0.16, green: 0.10, blue: 0.28))
          .multilineTextAlignment(.leading)

        Text("\(transaction.categoryName) • \(transaction.paymentMethod)")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(Color(red: 0.43, green: 0.40, blue: 0.53))

        Text(Self.formattedDay(from: transaction.transactionDate))
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(Color(red: 0.43, green: 0.40, blue: 0.53))
      }

      Spacer(minLength: 8)

      Text(Self.amountText(for: transaction))
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(Self.amountColor(for: transaction))
        .multilineTextAlignment(.trailing)
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color(red: 0.97, green: 0.95, blue: 1.0))
    )
  }

  private static func formattedDay(from value: String) -> String {
    let parser = ISO8601DateFormatter()
    parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let fallbackParser = ISO8601DateFormatter()

    guard let date = parser.date(from: value) ?? fallbackParser.date(from: value) else {
      return value
    }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_IN")
    formatter.dateFormat = "EEE, d MMM yyyy"
    return formatter.string(from: date)
  }

  private static func amountText(for transaction: AIInsightsSnapshot.Transaction) -> String {
    let prefix = transaction.type == "income" ? "+" : "-"
    return "\(prefix)\(AIInsightsChatViewModel.currency(transaction.amount))"
  }

  private static func amountColor(for transaction: AIInsightsSnapshot.Transaction) -> Color {
    transaction.type == "income"
      ? Color(red: 0.13, green: 0.73, blue: 0.42)
      : Color(red: 0.91, green: 0.32, blue: 0.39)
  }
}

private struct _UserBubble: View {
  let text: String

  var body: some View {
    Text(text)
      .font(.system(size: 15, weight: .medium))
      .foregroundStyle(.white)
      .padding(.horizontal, 16)
      .padding(.vertical, 14)
      .background(Color.white.opacity(0.16))
      .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
  }
}

private struct _TypingBubble: View {
  var body: some View {
    TimelineView(.animation) { context in
      let step = Int(context.date.timeIntervalSinceReferenceDate * 2.6)

      HStack(spacing: 10) {
        ForEach(0..<3, id: \.self) { index in
          Circle()
            .fill(Color(red: 0.31, green: 0.19, blue: 0.56).opacity(step % 3 == index ? 1 : 0.35))
            .frame(width: step % 3 == index ? 9 : 7, height: step % 3 == index ? 9 : 7)
            .animation(.easeInOut(duration: 0.18), value: step)
        }
        Text("Analyzing")
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(Color(red: 0.31, green: 0.19, blue: 0.56))
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
  }
}

private final class AIInsightsChatViewModel: ObservableObject {
  @Published var messages: [AIChatMessage] = []
  @Published var draft: String = ""
  @Published var isLoading = false
  @Published var followUpPrompts: [String] = []

  private let snapshot: AIInsightsSnapshot
#if canImport(FoundationModels)
  private var sessionBox: Any?
#endif

  init(snapshot: AIInsightsSnapshot) {
    self.snapshot = snapshot
    self.messages = [
      AIChatMessage(
        role: .assistant,
        text: AIInsightsChatViewModel.initialMessage(for: snapshot)
      )
    ]
    self.followUpPrompts = AIInsightsChatViewModel.starterPrompts(for: snapshot)

#if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      sessionBox = LanguageModelSession(
        instructions: AIInsightsChatViewModel.instructions(for: snapshot)
      )
    }
#endif
  }

  var starterPrompts: [String] {
    AIInsightsChatViewModel.starterPrompts(for: snapshot)
  }

  var statementFilterPrompts: [String] {
    AIInsightsChatViewModel.statementFilterPrompts()
  }

  var insightCards: [AIInsightCardModel] {
    var cards: [AIInsightCardModel] = []

    if let highlight = snapshot.signals?.overspendingHighlights.first {
      cards.append(
        AIInsightCardModel(
          title: "Budget Risk",
          value: highlight.categoryName,
          caption: "\(Int((highlight.progress * 100).rounded()))% used of \(Self.currency(highlight.limitAmount))",
          icon: "exclamationmark.triangle.fill",
          tint: Color(red: 1.0, green: 0.74, blue: 0.36)
        )
      )
    }

    if let anomaly = snapshot.signals?.transactionAnomalies.first {
      cards.append(
        AIInsightCardModel(
          title: "Large Expense",
          value: anomaly.title,
          caption: "\(Self.currency(anomaly.amount)) via \(anomaly.paymentMethod)",
          icon: "waveform.path.ecg",
          tint: Color(red: 1.0, green: 0.53, blue: 0.56)
        )
      )
    }

    if let topUp = snapshot.signals?.suggestedGoalTopUp, topUp > 0 {
      cards.append(
        AIInsightCardModel(
          title: "Goal Top-Up",
          value: Self.currency(topUp),
          caption: "Suggested contribution per goal from current cash flow",
          icon: "flag.checkered.2.crossed",
          tint: Color(red: 0.55, green: 0.90, blue: 0.72)
        )
      )
    }

    if cards.isEmpty, let summary = snapshot.summary {
      cards.append(
        AIInsightCardModel(
          title: "Current Balance",
          value: Self.currency(summary.balance),
          caption: "Income \(Self.currency(summary.income)) vs expenses \(Self.currency(summary.expenses))",
          icon: "sparkles",
          tint: Color(red: 0.82, green: 0.70, blue: 1.0)
        )
      )
    }

    return cards
  }

  func send(prompt: String) {
    let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedPrompt.isEmpty, !isLoading else {
      return
    }

    draft = ""
    messages.append(AIChatMessage(role: .user, text: trimmedPrompt))

    if let statementResponse = statementTransactionsResponse(for: trimmedPrompt) {
      messages.append(
        AIChatMessage(
          role: .assistant,
          text: statementResponse.text,
          transactions: statementResponse.transactions
        )
      )
      followUpPrompts = nextFollowUps(for: trimmedPrompt)
      return
    }

    if let transaction = latestCategoryTransaction(for: trimmedPrompt) {
      let categoryDay = formattedDay(from: transaction.transactionDate)
      let amount = Self.currency(transaction.amount)
      let intro = "Your latest \(transaction.categoryName) transaction was \(transaction.title) on \(categoryDay) for \(amount) via \(transaction.paymentMethod)."
      messages.append(
        AIChatMessage(
          role: .assistant,
          text: intro,
          transactions: [transaction]
        )
      )
      followUpPrompts = nextFollowUps(for: trimmedPrompt)
      return
    }

    if wantsRecentTransactionList(prompt: trimmedPrompt) {
      messages.append(
        AIChatMessage(
          role: .assistant,
          text: "Here are your last 10 transactions with the exact day for each one.",
          transactions: Array(snapshot.recentTransactions.prefix(10))
        )
      )
      followUpPrompts = nextFollowUps(for: trimmedPrompt)
      return
    }

    isLoading = true

#if canImport(FoundationModels)
    if #available(iOS 26.0, *),
      let session = sessionBox as? LanguageModelSession
    {
      messages.append(AIChatMessage(role: .assistant, text: ""))
      let responseIndex = messages.count - 1

      Task { @MainActor in
        do {
          let stream = session.streamResponse(to: trimmedPrompt)
          for try await partial in stream {
            guard messages.indices.contains(responseIndex) else { continue }
            messages[responseIndex].text = partial.content
          }
          if messages[responseIndex].text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            messages[responseIndex].text = fallbackResponse(for: trimmedPrompt)
          }
          followUpPrompts = nextFollowUps(for: trimmedPrompt)
        } catch {
          if messages.indices.contains(responseIndex) {
            messages[responseIndex].text = fallbackResponse(for: trimmedPrompt)
          } else {
            messages.append(AIChatMessage(role: .assistant, text: fallbackResponse(for: trimmedPrompt)))
          }
          followUpPrompts = nextFollowUps(for: trimmedPrompt)
        }
        isLoading = false
      }
      return
    }
#endif

    Task { @MainActor in
      messages.append(AIChatMessage(role: .assistant, text: fallbackResponse(for: trimmedPrompt)))
      followUpPrompts = nextFollowUps(for: trimmedPrompt)
      isLoading = false
    }
  }

  private static func initialMessage(for snapshot: AIInsightsSnapshot) -> String {
    let expenseText = currency(snapshot.summary?.expenses ?? 0)
    let balanceText = currency(snapshot.summary?.balance ?? 0)
    let overspendingCount = snapshot.signals?.overspendingHighlights.count ?? 0
    let anomalyCount = snapshot.signals?.transactionAnomalies.count ?? 0
    var lead = "I can summarize spending patterns, budget pressure, and goal progress from your current finance data. Right now, your balance is \(balanceText) and expenses are \(expenseText)."
    if overspendingCount > 0 {
      lead += " I’m already seeing \(overspendingCount) budget area\(overspendingCount == 1 ? "" : "s") that need attention."
    }
    if anomalyCount > 0 {
      lead += " I also spotted \(anomalyCount) unusually large expense\(anomalyCount == 1 ? "" : "s")."
    }
    return "\(lead) Ask me for a quick monthly readout or a category breakdown."
  }

  private static func starterPrompts(for snapshot: AIInsightsSnapshot) -> [String] {
    var prompts: [String] = []

    let atRiskBudgets = snapshot.budgets.filter { $0.progress >= 0.8 || $0.health != "onTrack" }
    if let topBudget = atRiskBudgets.max(by: { $0.progress < $1.progress }) {
      prompts.append("Why is \(topBudget.categoryName) at risk?")
    } else {
      prompts.append("Which budget should I watch?")
    }

    if let topGoal = snapshot.goals.min(by: { $0.progress < $1.progress }) {
      prompts.append("How can I improve \(topGoal.title)?")
    } else {
      prompts.append("How are my savings goals doing?")
    }

    let topExpenseCategory = Dictionary(
      grouping: snapshot.recentTransactions.filter { $0.type == "expense" },
      by: \.categoryName
    )
      .mapValues { $0.reduce(0) { $0 + $1.amount } }
      .max(by: { $0.value < $1.value })?.key

    if let topExpenseCategory {
      prompts.append("Explain my \(topExpenseCategory) spending")
    } else {
      prompts.append("Summarize my recent spending")
    }

    if let anomaly = snapshot.signals?.transactionAnomalies.first {
      prompts.append("Why was \(anomaly.title) unusually high?")
    }

    prompts.append("What should I watch this month?")
    return Array(prompts.prefix(4))
  }

  private static func statementFilterPrompts() -> [String] {
    [
      "Today's transactions",
      "Yesterday's transactions",
      "This week's transactions",
      "Last week's transactions",
      "This month's transactions",
      "Last month's transactions",
      "Last 3 months transactions",
      "Year to date transactions",
      "Transactions from 01/03/2026 to 31/03/2026"
    ]
  }

  private static func instructions(for snapshot: AIInsightsSnapshot) -> String {
    let dataSummary = """
    Summary:
    Balance: \(snapshot.summary?.balance ?? 0)
    Income: \(snapshot.summary?.income ?? 0)
    Expenses: \(snapshot.summary?.expenses ?? 0)
    Savings: \(snapshot.summary?.savings ?? 0)
    Budget used ratio: \(snapshot.summary?.budgetUsed ?? 0)

    Budgets:
    \(snapshot.budgets.map { "\($0.categoryName): limit \($0.limitAmount), spent \($0.spentAmount), remaining \($0.remainingAmount), health \($0.health)" }.joined(separator: "\n"))

    Goals:
    \(snapshot.goals.map { "\($0.title): current \($0.currentAmount), target \($0.targetAmount), progress \($0.progress), status \($0.status)" }.joined(separator: "\n"))

    Recent Transactions:
    \(snapshot.recentTransactions.map { "\($0.type) \($0.title) - \($0.categoryName) - \($0.amount) via \($0.paymentMethod)" }.joined(separator: "\n"))

    Signals:
    Average expense amount: \(snapshot.signals?.averageExpense ?? 0)
    Suggested goal top-up: \(snapshot.signals?.suggestedGoalTopUp ?? 0)
    Overspending highlights: \(snapshot.signals?.overspendingHighlights.map { "\($0.categoryName) at \($0.progress)" }.joined(separator: ", ") ?? "none")
    Transaction anomalies: \(snapshot.signals?.transactionAnomalies.map { "\($0.title) \($0.amount)" }.joined(separator: ", ") ?? "none")
    """

    return """
    You are FinSense AI, an on-device personal finance insights assistant.
    You help the user understand budgeting, spending patterns, savings goals, and cash-flow habits using only the provided data.
    Give concise, calm, practical insight in plain language.
    When the user asks about recent spending, latest spending, recent spends, or latest transactions, list the last 10 transactions explicitly.
    For each listed transaction, include the exact calendar day from the provided transaction date, the title, category, payment method, and amount.
    Prefer concrete transaction lists over vague summaries for those requests.
    Do not provide investment advice, tax advice, credit advice, loan advice, or regulated financial recommendations.
    If asked for those, say you can only help with spending, budgeting, and goal-tracking insights.
    Use bullet-style structure when useful, but keep responses short and actionable.

    Current finance context:
    \(dataSummary)
    """
  }

  private func fallbackResponse(for prompt: String) -> String {
    let lowercased = prompt.lowercased()
    if let statementResponse = statementTransactionsResponse(for: prompt) {
      return statementResponse.text
    }
    if lowercased.contains("anomal") || lowercased.contains("unusual") || lowercased.contains("high") {
      guard let anomaly = snapshot.signals?.transactionAnomalies.first else {
        return "I’m not seeing a strong transaction anomaly right now. Your recent expenses look fairly close to your normal range."
      }
      return "\(anomaly.title) stands out because it is materially above your recent average expense size. It’s worth double-checking whether it was planned, one-off, or a category starting to drift."
    }
    if lowercased.contains("top-up") || lowercased.contains("top up") || lowercased.contains("contribute") {
      let suggestedTopUp = snapshot.signals?.suggestedGoalTopUp ?? 0
      if suggestedTopUp <= 0 {
        return "Cash flow looks tight right now, so I wouldn’t suggest an aggressive goal top-up from this cycle. Stabilizing spending first would give you a healthier base."
      }
      return "A reasonable goal top-up from this cycle is about \(Self.currency(suggestedTopUp)) per goal. That keeps contributions aligned with current cash flow instead of forcing the plan."
    }
    if lowercased.contains("budget") {
      let warningBudgets = snapshot.signals?.overspendingHighlights ?? snapshot.budgets.filter { $0.progress >= 0.8 || $0.health != "onTrack" }
      if warningBudgets.isEmpty {
        return "Your current budgets look reasonably stable. None of the tracked categories are near their limit right now."
      }
      let summary = warningBudgets.prefix(3).map { "\($0.categoryName) is at \(Int(($0.progress * 100).rounded()))% of its limit." }.joined(separator: " ")
      return "Here’s the quick budget read: \(summary) If spending stays at the same pace, those categories deserve closer attention first."
    }
    if lowercased.contains("goal") || lowercased.contains("saving") {
      guard let topGoal = snapshot.goals.max(by: { $0.progress < $1.progress }) else {
        return "I don’t see any savings goals yet. Creating even one simple target can make the rest of the analysis more useful."
      }
      return "\(topGoal.title) is your strongest visible goal right now at \(Int((topGoal.progress * 100).rounded()))% progress. A consistent small top-up will usually matter more than a one-off adjustment."
    }
    if lowercased.contains("recent spend") ||
      lowercased.contains("recent spending") ||
      lowercased.contains("last 10") ||
      lowercased.contains("latest transaction") ||
      lowercased.contains("recent transaction") ||
      lowercased.contains("recent expense")
    {
      return recentTransactionsListResponse()
    }
    if lowercased.contains("spending") || lowercased.contains("expense") {
      let categories = Dictionary(grouping: snapshot.recentTransactions.filter { $0.type == "expense" }, by: \.categoryName)
      let topCategory = categories
        .mapValues { $0.reduce(0) { $0 + $1.amount } }
        .max(by: { $0.value < $1.value })
      if let topCategory {
        return "\(recentTransactionsListResponse())\n\nYour recent spending is concentrated most heavily in \(topCategory.key). That’s the first category I’d review if you want a fast improvement."
      }
      return recentTransactionsListResponse()
    }

    if let quickInsight = snapshot.quickInsight, !quickInsight.isEmpty {
      return quickInsight
    }
    return "I can help summarize budgets, spending categories, and savings progress from your current data. Try asking which budget needs attention or what changed in your recent spending."
  }

  private func nextFollowUps(for prompt: String) -> [String] {
    let lowercased = prompt.lowercased()
    if statementTransactionsResponse(for: prompt) != nil {
      return [
        "Show last week's transactions",
        "Show this month's transactions",
        "Which category appears most in this range?"
      ]
    }
    if lowercased.contains("recent spend") ||
      lowercased.contains("recent spending") ||
      lowercased.contains("latest transaction") ||
      lowercased.contains("recent transaction")
    {
      return [
        "Which spending category appears most often?",
        "Which of these transactions is unusually high?",
        "How do these affect my budget?"
      ]
    }
    if lowercased.contains("anomal") || lowercased.contains("unusual") || lowercased.contains("high") {
      return [
        "Which expense category is drifting most?",
        "How does this affect my monthly balance?",
        "What should I watch next?"
      ]
    }
    if lowercased.contains("top-up") || lowercased.contains("top up") || lowercased.contains("contribute") {
      return [
        "Which goal should get the first top-up?",
        "How are my goals doing overall?",
        "Can I afford more this month?"
      ]
    }
    if lowercased.contains("budget") {
      return [
        "Which category needs action first?",
        "How close am I to my budget limits?",
        "Show my safest budget"
      ]
    }
    if lowercased.contains("goal") || lowercased.contains("saving") {
      return [
        "Which goal is furthest behind?",
        "What is my strongest goal?",
        "How much progress did I make overall?"
      ]
    }
    if lowercased.contains("spending") || lowercased.contains("expense") {
      return [
        "What is my top spending category?",
        "Which recent transactions stand out?",
        "How does this affect my balance?"
      ]
    }
    return [
      "Which budgets are at risk?",
      "Why was a transaction unusually high?",
      "Suggest a goal top-up amount",
      "Summarize my recent spending",
      "How are my goals doing?"
    ]
  }

  static func currency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "INR"
    formatter.locale = Locale(identifier: "en_IN")
    return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
  }

  private func wantsRecentTransactionList(prompt: String) -> Bool {
    let lowercased = prompt.lowercased()
    return lowercased.contains("recent spend") ||
      lowercased.contains("recent spending") ||
      lowercased.contains("last 10") ||
      lowercased.contains("latest transaction") ||
      lowercased.contains("recent transaction") ||
      lowercased.contains("recent expense")
  }

  private func statementTransactionsResponse(for prompt: String) -> AITransactionListResponse? {
    let lowercased = prompt.lowercased()
    guard
      lowercased.contains("transaction") ||
      lowercased.contains("statement") ||
      lowercased.contains("spend") ||
      lowercased.contains("expense")
    else {
      return nil
    }

    guard let range = statementDateRange(for: lowercased) else {
      return nil
    }

    let matchedCategory = matchedCategoryName(in: lowercased)
    let filteredTransactions = snapshot.recentTransactions.filter { transaction in
      guard let transactionDate = parsedDate(from: transaction.transactionDate) else {
        return false
      }
      let isInRange = transactionDate >= range.start && transactionDate <= range.end
      guard isInRange else {
        return false
      }
      if let matchedCategory {
        return normalizedSearchText(transaction.categoryName) == normalizedSearchText(matchedCategory)
      }
      return true
    }

    let titlePrefix = matchedCategory == nil ? "Here are" : "Here are"
    if filteredTransactions.isEmpty {
      let categoryText = matchedCategory == nil ? "" : " for \(matchedCategory)"
      return AITransactionListResponse(
        text: "I couldn’t find any transactions\(categoryText) in \(range.label).",
        transactions: []
      )
    }

    let categoryText = matchedCategory == nil ? "" : " for \(matchedCategory)"
    return AITransactionListResponse(
      text: "\(titlePrefix) \(filteredTransactions.count) transaction\(filteredTransactions.count == 1 ? "" : "s")\(categoryText) in \(range.label).",
      transactions: filteredTransactions
    )
  }

  private func latestCategoryTransaction(for prompt: String) -> AIInsightsSnapshot.Transaction? {
    let lowercased = prompt.lowercased()
    guard
      lowercased.contains("last") || lowercased.contains("latest"),
      lowercased.contains("transaction") || lowercased.contains("spend") || lowercased.contains("expense")
    else {
      return nil
    }

    let expenseTransactions = snapshot.recentTransactions.filter { $0.type == "expense" }
    guard !expenseTransactions.isEmpty else {
      return nil
    }

    let normalizedPrompt = normalizedSearchText(lowercased)
    let bestCategory = bestCategoryName(in: normalizedPrompt, candidates: expenseTransactions.map(\.categoryName))

    guard let bestCategory else {
      return nil
    }

    return expenseTransactions.first { $0.categoryName == bestCategory }
  }

  private func matchedCategoryName(in prompt: String) -> String? {
    bestCategoryName(
      in: normalizedSearchText(prompt),
      candidates: snapshot.recentTransactions
        .filter { $0.type == "expense" }
        .map(\.categoryName)
    )
  }

  private func bestCategoryName(in normalizedPrompt: String, candidates: [String]) -> String? {
    Set(candidates).compactMap { categoryName -> (String, Int)? in
      let categoryTokens = categoryTokens(for: categoryName)
      let score = categoryTokens.reduce(into: 0) { partial, token in
        if normalizedPrompt.contains(token) {
          partial += token.count >= 5 ? 3 : 2
        }
      }
      guard score > 0 else {
        return nil
      }
      return (categoryName, score)
    }
    .sorted { lhs, rhs in
      if lhs.1 == rhs.1 {
        return lhs.0 < rhs.0
      }
      return lhs.1 > rhs.1
    }
    .first?.0
  }

  private func categoryTokens(for categoryName: String) -> [String] {
    var tokens = normalizedSearchText(categoryName)
      .split(separator: " ")
      .map(String.init)
      .filter { $0.count >= 3 }

    let normalizedCategory = normalizedSearchText(categoryName)

    if normalizedCategory.contains("dining") {
      tokens.append(contentsOf: ["dining", "dinning", "restaurant", "food", "meal", "cafe"])
    }
    if normalizedCategory.contains("grocer") {
      tokens.append(contentsOf: ["grocery", "groceries", "market", "supermarket"])
    }
    if normalizedCategory.contains("transport") {
      tokens.append(contentsOf: ["transport", "travel", "commute", "cab", "fuel"])
    }

    return Array(Set(tokens))
  }

  private func normalizedSearchText(_ value: String) -> String {
    value
      .lowercased()
      .replacingOccurrences(of: "dinning", with: "dining")
      .components(separatedBy: CharacterSet.alphanumerics.inverted)
      .filter { !$0.isEmpty }
      .joined(separator: " ")
  }

  private func recentTransactionsListResponse() -> String {
    guard !snapshot.recentTransactions.isEmpty else {
      return "I don’t have any recent transactions to list yet."
    }

    let lines = snapshot.recentTransactions.prefix(10).map { transaction in
      let dayText = formattedDay(from: transaction.transactionDate)
      let amountText = Self.currency(transaction.amount)
      return "• \(dayText): \(transaction.title) (\(transaction.categoryName)) via \(transaction.paymentMethod) for \(amountText)"
    }

    return "Here are your last 10 transactions:\n" + lines.joined(separator: "\n")
  }

  private func statementDateRange(for prompt: String) -> (start: Date, end: Date, label: String)? {
    let calendar = Calendar.current
    let now = Date()

    if let explicitRange = explicitDateRange(in: prompt) {
      return explicitRange
    }
    if prompt.contains("today") {
      let start = calendar.startOfDay(for: now)
      let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? now
      return (start, end, "today")
    }
    if prompt.contains("yesterday") {
      let startOfToday = calendar.startOfDay(for: now)
      let start = calendar.date(byAdding: .day, value: -1, to: startOfToday) ?? startOfToday
      let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? start
      return (start, end, "yesterday")
    }
    if prompt.contains("last week") {
      return weekRange(weeksAgo: 1, calendar: calendar, now: now, label: "last week")
    }
    if prompt.contains("this week") || prompt.contains("week to week") {
      return weekRange(weeksAgo: 0, calendar: calendar, now: now, label: "this week")
    }
    if prompt.contains("last month") {
      return monthRange(monthsAgo: 1, calendar: calendar, now: now, label: "last month")
    }
    if prompt.contains("this month") {
      return monthRange(monthsAgo: 0, calendar: calendar, now: now, label: "this month")
    }
    if prompt.contains("last 3 month") || prompt.contains("last three month") {
      let start = calendar.date(byAdding: .month, value: -3, to: calendar.startOfDay(for: now)) ?? now
      return (start, now, "the last 3 months")
    }
    if prompt.contains("year to date") || prompt.contains("ytd") {
      let components = calendar.dateComponents([.year], from: now)
      let start = calendar.date(from: components) ?? now
      return (start, now, "year to date")
    }
    return nil
  }

  private func explicitDateRange(in prompt: String) -> (start: Date, end: Date, label: String)? {
    let patterns = [
      "\\b\\d{4}-\\d{2}-\\d{2}\\b",
      "\\b\\d{1,2}/\\d{1,2}/\\d{4}\\b",
      "\\b\\d{1,2}-\\d{1,2}-\\d{4}\\b"
    ]

    var matches: [String] = []
    for pattern in patterns {
      guard let regex = try? NSRegularExpression(pattern: pattern) else {
        continue
      }
      let nsPrompt = prompt as NSString
      matches.append(
        contentsOf: regex.matches(in: prompt, range: NSRange(location: 0, length: nsPrompt.length))
          .map { nsPrompt.substring(with: $0.range) }
      )
    }

    guard matches.count >= 2,
      let first = parsedInputDate(matches[0]),
      let second = parsedInputDate(matches[1])
    else {
      return nil
    }

    let start = min(first, second)
    let rawEnd = max(first, second)
    let calendar = Calendar.current
    let end = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: calendar.startOfDay(for: rawEnd)) ?? rawEnd
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_IN")
    formatter.dateFormat = "d MMM yyyy"
    return (start, end, "\(formatter.string(from: start)) to \(formatter.string(from: rawEnd))")
  }

  private func parsedInputDate(_ value: String) -> Date? {
    let formatters = ["yyyy-MM-dd", "dd/MM/yyyy", "d/M/yyyy", "dd-MM-yyyy", "d-M-yyyy"].map { format in
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_IN")
      formatter.dateFormat = format
      formatter.timeZone = TimeZone.current
      return formatter
    }

    for formatter in formatters {
      if let date = formatter.date(from: value) {
        return Calendar.current.startOfDay(for: date)
      }
    }
    return nil
  }

  private func weekRange(
    weeksAgo: Int,
    calendar: Calendar,
    now: Date,
    label: String
  ) -> (start: Date, end: Date, label: String)? {
    guard
      let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now),
      let start = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: weekInterval.start)
    else {
      return nil
    }
    let endBase = calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? start
    let end = calendar.date(byAdding: .second, value: -1, to: endBase) ?? endBase
    return (start, end, label)
  }

  private func monthRange(
    monthsAgo: Int,
    calendar: Calendar,
    now: Date,
    label: String
  ) -> (start: Date, end: Date, label: String)? {
    guard
      let monthInterval = calendar.dateInterval(of: .month, for: now),
      let start = calendar.date(byAdding: .month, value: -monthsAgo, to: monthInterval.start)
    else {
      return nil
    }
    let endBase = calendar.date(byAdding: .month, value: 1, to: start) ?? start
    let end = calendar.date(byAdding: .second, value: -1, to: endBase) ?? endBase
    return (start, end, label)
  }

  private func parsedDate(from isoDate: String) -> Date? {
    let parser = ISO8601DateFormatter()
    parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let fallbackParser = ISO8601DateFormatter()
    return parser.date(from: isoDate) ?? fallbackParser.date(from: isoDate)
  }

  private func formattedDay(from isoDate: String) -> String {
    let parser = ISO8601DateFormatter()
    parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let fallbackParser = ISO8601DateFormatter()

    let date =
      parser.date(from: isoDate) ??
      fallbackParser.date(from: isoDate)

    guard let date else {
      return isoDate
    }

    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_IN")
    formatter.dateFormat = "EEE, d MMM yyyy"
    return formatter.string(from: date)
  }
}
