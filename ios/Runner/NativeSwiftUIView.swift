import Flutter
import Foundation
import PhotosUI
import SwiftUI
import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

private enum FinSenseTypeScale {
  static let hero: CGFloat = 26
  static let title: CGFloat = 20
  static let body: CGFloat = 15
  static let label: CGFloat = 13
  static let caption: CGFloat = 12
}

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
          .font(.system(size: FinSenseTypeScale.hero, weight: .bold, design: .rounded))
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
      UITabBarItem(title: "Plan", image: UIImage(systemName: "square.grid.2x2"), selectedImage: UIImage(systemName: "square.grid.2x2.fill")),
      UITabBarItem(title: "Insights", image: UIImage(systemName: "sparkles.rectangle.stack"), selectedImage: UIImage(systemName: "sparkles.rectangle.stack.fill")),
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

struct UnsupportedBillScannerView: View {
  let onDismiss: () -> Void

  @State private var showAlert = true

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.97, green: 0.95, blue: 1.0),
          Color.white
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()
    }
    .alert("iOS 26 Required", isPresented: $showAlert) {
      Button("OK") {
        onDismiss()
      }
    } message: {
      Text("Bill scanning is available only on iOS 26 or newer.")
    }
    .onAppear {
      showAlert = true
    }
  }
}

@available(iOS 26.0, *)
struct BillScannerHostView: View {
  let channel: FlutterMethodChannel
  let onClose: () -> Void

  private let defaultBillAssetName = "11Grocery"

  @StateObject private var visionModel = VisionModel()
  @State private var pickerSource: UIImagePickerController.SourceType?
  @State private var pickedImageData: Data?
  @State private var isShowingSourceOptions = false
  @State private var isShowingImagePicker = false

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.97, green: 0.95, blue: 1.0),
          Color.white
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(alignment: .leading, spacing: 20) {
        HStack {
          Button(action: onClose) {
            Image(systemName: "chevron.left")
              .font(.system(size: 17, weight: .semibold))
              .foregroundStyle(Color.black)
              .frame(width: 42, height: 42)
              .background(Color.white)
              .clipShape(Circle())
          }
          Spacer()
        }

        Text("Scan Bill")
          .font(.system(size: FinSenseTypeScale.hero, weight: .bold))
          .foregroundStyle(Color.black)

        Text("FinSense starts with a default sample bill for testing. You can still switch to camera or photo library any time.")
          .font(.system(size: FinSenseTypeScale.body))
          .foregroundStyle(Color.black.opacity(0.65))

        RoundedRectangle(cornerRadius: 28, style: .continuous)
          .fill(Color.white)
          .overlay {
            VStack(spacing: 16) {
              Image(systemName: pickedImageData == nil ? "doc.text.viewfinder" : "checkmark.circle.fill")
                .font(.system(size: 46, weight: .medium))
                .foregroundStyle(pickedImageData == nil ? Color.blue : Color.green)

              if let pickedImageData, let image = UIImage(data: pickedImageData) {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFit()
                  .frame(maxHeight: 260)
                  .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
              } else {
                Text("No bill selected yet")
                  .font(.system(size: FinSenseTypeScale.body, weight: .semibold))
                  .foregroundStyle(Color.black)
              }

              if let scannedBill = visionModel.scannedBill {
                VStack(alignment: .leading, spacing: 8) {
                  Text(scannedBill.title)
                    .font(.system(size: FinSenseTypeScale.body, weight: .semibold))
                  Text("Detected total: \(scannedBill.currencySymbol)\(String(format: "%.2f", scannedBill.totalAmount))")
                    .font(.system(size: FinSenseTypeScale.body, weight: .medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(red: 0.95, green: 0.98, blue: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
              }
            }
            .padding(20)
          }

        VStack(spacing: 12) {
          Button(action: {
            isShowingSourceOptions = true
          }) {
            Text(pickedImageData == nil ? "Choose Camera or Photo Instead" : "Scan Another Bill")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)

          if pickedImageData != nil {
            Button(role: .cancel, action: {
              pickedImageData = nil
              visionModel.resetState()
            }) {
              Text("Clear")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
          }
        }

        Spacer()
      }
      .padding(20)

      LoadingOverlayView(loadingText: visionModel.loadingText)
    }
    .confirmationDialog("Select Source", isPresented: $isShowingSourceOptions) {
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        Button("Camera") {
          pickerSource = .camera
          isShowingImagePicker = true
        }
      }
      Button("Photo Library") {
        pickerSource = .photoLibrary
        isShowingImagePicker = true
      }
      Button("Cancel", role: .cancel) {}
    }
    .sheet(isPresented: $isShowingImagePicker) {
      if let pickerSource {
        BillImagePicker(sourceType: pickerSource) { data in
          pickedImageData = data
          Task {
            await processBill(data)
          }
        }
      }
    }
    .task {
      await loadDefaultBillIfNeeded()
    }
  }

  @MainActor
  private func processBill(_ imageData: Data) async {
    guard let scannedBill = await visionModel.recognizeBill(in: imageData) else {
      channel.invokeMethod(
        "scanFailed",
        arguments: ["message": "I couldn’t detect a bill total from that image."]
      )
      return
    }

    channel.invokeMethod(
      "scanCompleted",
      arguments: [
        "title": scannedBill.title,
        "amount": scannedBill.totalAmount,
        "currencySymbol": scannedBill.currencySymbol,
        "date": scannedBill.date
      ]
    )
  }

  @MainActor
  private func loadDefaultBillIfNeeded() async {
    guard pickedImageData == nil,
          visionModel.scannedBill == nil,
          let imageData = defaultBillImageData()
    else {
      return
    }

    pickedImageData = imageData
    await processBill(imageData)
  }

  private func defaultBillImageData() -> Data? {
    if let assetData = UIImage(named: defaultBillAssetName)?.pngData() {
      return assetData
    }

    if let bundledURL = Bundle.main.url(
      forResource: defaultBillAssetName,
      withExtension: "png",
      subdirectory: "DocumentScanner/Assets"
    ) {
      return try? Data(contentsOf: bundledURL)
    }

    return nil
  }
}

@available(iOS 26.0, *)
struct BillImagePicker: UIViewControllerRepresentable {
  let sourceType: UIImagePickerController.SourceType
  let onImagePicked: (Data) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(onImagePicked: onImagePicked)
  }

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = sourceType
    picker.allowsEditing = false
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let onImagePicked: (Data) -> Void

    init(onImagePicked: @escaping (Data) -> Void) {
      self.onImagePicked = onImagePicked
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true)
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      defer {
        picker.dismiss(animated: true)
      }

      guard let image = info[.originalImage] as? UIImage,
            let data = image.jpegData(compressionQuality: 0.9) else {
        return
      }

      onImagePicked(data)
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
            Text("Ask FinSense")
              .font(.system(size: FinSenseTypeScale.hero, weight: .bold, design: .rounded))
              .foregroundStyle(.white)
            Text("Explore your spending in plain language, right on device.")
              .font(.system(size: FinSenseTypeScale.body, weight: .medium))
              .foregroundStyle(.white.opacity(0.78))
          }
          Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(model.starterPrompts, id: \.self) { prompt in
              Button {
                model.send(prompt: prompt)
              } label: {
                Text(prompt)
                  .font(.system(size: FinSenseTypeScale.label, weight: .semibold))
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
                        .font(.system(size: FinSenseTypeScale.caption, weight: .semibold))
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
            TextField("Try: card spends this month or travel above 1000", text: $model.draft, axis: .vertical)
              .textFieldStyle(.plain)
              .font(.system(size: FinSenseTypeScale.body, weight: .medium))
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

  func send(prompt: String) {
    let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedPrompt.isEmpty, !isLoading else {
      return
    }

    draft = ""
    messages.append(AIChatMessage(role: .user, text: trimmedPrompt))

    if let comparisonResponse = periodComparisonResponse(for: trimmedPrompt) {
      messages.append(
        AIChatMessage(
          role: .assistant,
          text: comparisonResponse
        )
      )
      followUpPrompts = nextFollowUps(for: trimmedPrompt)
      return
    }

    if let filteredResponse = transactionExplorerResponse(for: trimmedPrompt) {
      messages.append(
        AIChatMessage(
          role: .assistant,
          text: filteredResponse.text,
          transactions: filteredResponse.transactions
        )
      )
      followUpPrompts = nextFollowUps(for: trimmedPrompt)
      return
    }

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
    return """
    I’m your on-device spend explorer. I’m best at:
    • card spends this month
    • travel above 1000
    • compare this month vs last month

    Right now, your balance is \(balanceText) and expenses are \(expenseText).
    """
  }

  private static func starterPrompts(for snapshot: AIInsightsSnapshot) -> [String] {
    _ = snapshot
    return [
      "Card spends this month",
      "Travel above 1000",
      "Compare this month vs last month",
      "Show my recent transactions",
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
    You are FinSense AI, an on-device spend explorer.
    You help the user search, compare, and explain transaction activity using only the provided data.
    Your best tasks are:
    1. filtering transactions by date range, category, payment method, or amount
    2. comparing this month vs last month or this week vs last week
    3. summarizing what changed in recent spending
    Do not produce a full analytics report.
    Give concise, calm, practical insight in plain language.
    Prefer short answers with a helpful headline and 2 to 4 concrete points.
    When the user asks about recent spending, latest spending, recent spends, or latest transactions, list the last 10 transactions explicitly.
    For each listed transaction, include the exact calendar day from the provided transaction date, the title, category, payment method, and amount.
    Prefer concrete transaction lists over vague summaries for those requests.
    Do not provide investment advice, tax advice, credit advice, loan advice, or regulated financial recommendations.
    If asked for those, say you can only help with spending, budgeting, and goal-tracking insights.
    If the user asks what changed, compare periods, categories, and transaction activity.
    If the user asks outside these tasks, gently redirect them to FinSense Insights for deeper analysis.
    Use bullet-style structure when useful, but keep responses short and actionable.

    Current finance context:
    \(dataSummary)
    """
  }

  private func fallbackResponse(for prompt: String) -> String {
    let lowercased = prompt.lowercased()
    if let comparisonResponse = periodComparisonResponse(for: prompt) {
      return comparisonResponse
    }
    if let filteredResponse = transactionExplorerResponse(for: prompt) {
      return filteredResponse.text
    }
    if let statementResponse = statementTransactionsResponse(for: prompt) {
      return statementResponse.text
    }
    if lowercased.contains("changed") || lowercased.contains("month") || lowercased.contains("summary") {
      let categories = Dictionary(grouping: snapshot.recentTransactions.filter { $0.type == "expense" }, by: \.categoryName)
        .mapValues { $0.reduce(0) { $0 + $1.amount } }
      let topCategory = categories.max(by: { $0.value < $1.value })
      let budgetWarning = (snapshot.signals?.overspendingHighlights ?? []).first?.categoryName
      var response = "This month, your expenses are \(Self.currency(snapshot.summary?.expenses ?? 0)) against income of \(Self.currency(snapshot.summary?.income ?? 0))."
      if let topCategory {
        response += " Your biggest spending category is \(topCategory.key) at \(Self.currency(topCategory.value))."
      }
      if let budgetWarning {
        response += " \(budgetWarning) is the main budget to watch right now."
      }
      return response
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
      return recentTransactionsListResponse()
    }

    return "Try asking things like card spends this month, travel above 1000, or compare this month vs last month. For deeper analysis, open FinSense Insights."
  }

  private func nextFollowUps(for prompt: String) -> [String] {
    let lowercased = prompt.lowercased()
    if statementTransactionsResponse(for: prompt) != nil {
      return [
        "Compare this month vs last month",
        "Card spends this month",
      ]
    }
    if periodComparisonResponse(for: prompt) != nil {
      return [
        "Travel above 1000",
        "Show my recent transactions",
      ]
    }
    if transactionExplorerResponse(for: prompt) != nil {
      return [
        "Compare this month vs last month",
        "Show my recent transactions",
      ]
    }
    if lowercased.contains("recent spend") ||
      lowercased.contains("recent spending") ||
      lowercased.contains("latest transaction") ||
      lowercased.contains("recent transaction")
    {
      return [
        "Card spends this month",
        "Compare this month vs last month",
      ]
    }
    return [
      "Card spends this month",
      "Travel above 1000",
      "Compare this month vs last month",
      "Show my recent transactions",
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

  private enum AmountFilterKind {
    case minimum
    case maximum
  }

  private struct AmountFilter {
    let kind: AmountFilterKind
    let amount: Double
  }

  private func matchedAmountFilter(in prompt: String) -> AmountFilter? {
    let patterns: [(String, AmountFilterKind)] = [
      ("(?:above|over|greater than|more than)\\s*(?:rs\\.?|₹)?\\s*([\\d,]+(?:\\.\\d+)?)", .minimum),
      ("(?:below|under|less than)\\s*(?:rs\\.?|₹)?\\s*([\\d,]+(?:\\.\\d+)?)", .maximum)
    ]

    let nsPrompt = prompt as NSString
    for (pattern, kind) in patterns {
      guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
        continue
      }
      guard let match = regex.firstMatch(in: prompt, range: NSRange(location: 0, length: nsPrompt.length)),
        match.numberOfRanges > 1
      else {
        continue
      }

      let rawAmount = nsPrompt.substring(with: match.range(at: 1)).replacingOccurrences(of: ",", with: "")
      if let amount = Double(rawAmount) {
        return AmountFilter(kind: kind, amount: amount)
      }
    }
    return nil
  }

  private func matchedPaymentMethod(in prompt: String) -> String? {
    let normalizedPrompt = normalizedSearchText(prompt)
    let paymentMethods = Array(Set(snapshot.recentTransactions.map(\.paymentMethod)))
    return paymentMethods.first { method in
      normalizedPrompt.contains(normalizedSearchText(method))
    }
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

  private func totalAmount(in range: (start: Date, end: Date, label: String), type: String) -> Double {
    snapshot.recentTransactions.reduce(into: 0.0) { total, transaction in
      guard transaction.type == type,
        let transactionDate = parsedDate(from: transaction.transactionDate),
        transactionDate >= range.start,
        transactionDate <= range.end
      else {
        return
      }
      total += transaction.amount
    }
  }

  private func topCategory(in range: (start: Date, end: Date, label: String)) -> (name: String, amount: Double)? {
    let grouped = Dictionary(
      grouping: snapshot.recentTransactions.filter { transaction in
        guard transaction.type == "expense",
          let transactionDate = parsedDate(from: transaction.transactionDate)
        else {
          return false
        }
        return transactionDate >= range.start && transactionDate <= range.end
      },
      by: \.categoryName
    ).mapValues { $0.reduce(0) { $0 + $1.amount } }

    guard let top = grouped.max(by: { $0.value < $1.value }) else {
      return nil
    }
    return (top.key, top.value)
  }

  private func explorerHeadline(
    transactions: [AIInsightsSnapshot.Transaction],
    rangeLabel: String?,
    category: String?,
    paymentMethod: String?,
    amountFilter: AmountFilter?,
    isSortedByAmount: Bool
  ) -> String {
    var parts: [String] = []
    parts.append(isSortedByAmount ? "Here are the biggest matching transactions" : "Here are \(transactions.count) matching transactions")

    if let category {
      parts.append("for \(category)")
    }
    if let paymentMethod {
      parts.append("via \(paymentMethod)")
    }
    if let rangeLabel {
      parts.append("in \(rangeLabel)")
    }
    if let amountFilter {
      let comparator = amountFilter.kind == .minimum ? "above" : "below"
      parts.append("\(comparator) \(Self.currency(amountFilter.amount))")
    }

    return parts.joined(separator: " ") + "."
  }

  private func explorerEmptyState(
    rangeLabel: String?,
    category: String?,
    paymentMethod: String?,
    amountFilter: AmountFilter?
  ) -> String {
    var parts = ["I couldn’t find any transactions"]
    if let category {
      parts.append("for \(category)")
    }
    if let paymentMethod {
      parts.append("via \(paymentMethod)")
    }
    if let rangeLabel {
      parts.append("in \(rangeLabel)")
    }
    if let amountFilter {
      let comparator = amountFilter.kind == .minimum ? "above" : "below"
      parts.append("\(comparator) \(Self.currency(amountFilter.amount))")
    }
    return parts.joined(separator: " ") + "."
  }

  private func transactionExplorerResponse(for prompt: String) -> AITransactionListResponse? {
    let lowercased = prompt.lowercased()
    let range = statementDateRange(for: lowercased)
    let matchedCategory = matchedCategoryName(in: lowercased)
    let matchedPaymentMethod = matchedPaymentMethod(in: lowercased)
    let amountFilter = matchedAmountFilter(in: lowercased)
    let asksForTransactions =
      lowercased.contains("show") ||
      lowercased.contains("spent") ||
      lowercased.contains("spend") ||
      lowercased.contains("expense") ||
      lowercased.contains("transaction")

    guard asksForTransactions || matchedCategory != nil || matchedPaymentMethod != nil || amountFilter != nil else {
      return nil
    }

    var filteredTransactions = snapshot.recentTransactions.filter { transaction in
      if let range {
        guard let transactionDate = parsedDate(from: transaction.transactionDate) else {
          return false
        }
        guard transactionDate >= range.start && transactionDate <= range.end else {
          return false
        }
      }

      if let matchedCategory,
         normalizedSearchText(transaction.categoryName) != normalizedSearchText(matchedCategory) {
        return false
      }

      if let matchedPaymentMethod,
         normalizedSearchText(transaction.paymentMethod) != normalizedSearchText(matchedPaymentMethod) {
        return false
      }

      if let amountFilter {
        switch amountFilter.kind {
        case .minimum:
          guard transaction.amount >= amountFilter.amount else { return false }
        case .maximum:
          guard transaction.amount <= amountFilter.amount else { return false }
        }
      }

      if lowercased.contains("expense") || lowercased.contains("spent") || lowercased.contains("spend") {
        return transaction.type == "expense"
      }

      if lowercased.contains("income") {
        return transaction.type == "income"
      }

      return true
    }

    let sortByAmount =
      lowercased.contains("biggest") ||
      lowercased.contains("highest") ||
      lowercased.contains("largest")

    if sortByAmount {
      filteredTransactions.sort { $0.amount > $1.amount }
      filteredTransactions = Array(filteredTransactions.prefix(5))
    } else {
      filteredTransactions = Array(filteredTransactions.prefix(10))
    }

    guard !filteredTransactions.isEmpty else {
      return AITransactionListResponse(
        text: explorerEmptyState(
          rangeLabel: range?.label,
          category: matchedCategory,
          paymentMethod: matchedPaymentMethod,
          amountFilter: amountFilter
        ),
        transactions: []
      )
    }

    return AITransactionListResponse(
      text: explorerHeadline(
        transactions: filteredTransactions,
        rangeLabel: range?.label,
        category: matchedCategory,
        paymentMethod: matchedPaymentMethod,
        amountFilter: amountFilter,
        isSortedByAmount: sortByAmount
      ),
      transactions: filteredTransactions
    )
  }

  private func periodComparisonResponse(for prompt: String) -> String? {
    let lowercased = prompt.lowercased()
    let calendar = Calendar.current
    let now = Date()

    let currentRange: (start: Date, end: Date, label: String)?
    let previousRange: (start: Date, end: Date, label: String)?

    if lowercased.contains("this month") && lowercased.contains("last month") {
      currentRange = monthRange(monthsAgo: 0, calendar: calendar, now: now, label: "this month")
      previousRange = monthRange(monthsAgo: 1, calendar: calendar, now: now, label: "last month")
    } else if lowercased.contains("this week") && lowercased.contains("last week") {
      currentRange = weekRange(weeksAgo: 0, calendar: calendar, now: now, label: "this week")
      previousRange = weekRange(weeksAgo: 1, calendar: calendar, now: now, label: "last week")
    } else {
      return nil
    }

    guard lowercased.contains("compare"),
      let currentRange,
      let previousRange
    else {
      return nil
    }

    let currentExpenses = totalAmount(in: currentRange, type: "expense")
    let previousExpenses = totalAmount(in: previousRange, type: "expense")
    let currentIncome = totalAmount(in: currentRange, type: "income")
    let previousIncome = totalAmount(in: previousRange, type: "income")

    let currentTopCategory = topCategory(in: currentRange)
    let previousTopCategory = topCategory(in: previousRange)
    let expenseDelta = currentExpenses - previousExpenses
    let deltaDirection = expenseDelta >= 0 ? "up" : "down"

    var lines = [
      "Comparison: \(currentRange.label.capitalized) vs \(previousRange.label)",
      "• Expenses are \(deltaDirection) by \(Self.currency(abs(expenseDelta))) (\(Self.currency(currentExpenses)) vs \(Self.currency(previousExpenses))).",
      "• Income is \(Self.currency(currentIncome)) vs \(Self.currency(previousIncome)).",
    ]

    if let currentTopCategory {
      let previousText: String
      if let previousTopCategory {
        previousText = "Last period it was \(previousTopCategory.name) at \(Self.currency(previousTopCategory.amount))."
      } else {
        previousText = "No strong top category stood out last period."
      }
      lines.append("• Top spending category is \(currentTopCategory.name) at \(Self.currency(currentTopCategory.amount)). \(previousText)")
    }

    return lines.joined(separator: "\n")
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
