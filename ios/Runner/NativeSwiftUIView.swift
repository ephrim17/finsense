import Flutter
import SwiftUI
import UIKit

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
