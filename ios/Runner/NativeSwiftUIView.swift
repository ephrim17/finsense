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

        Text("Native surfaces for Flutter, designed to scale.")
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(.white)

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
              colors: [
                Color.cyan,
                Color.blue,
              ],
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
