//
//  LoadingView.swift
//  sample
//
//  Created by ephrim.daniel on 22/11/25.
//

import SwiftUI

struct LoadingOverlayView: View {
    var loadingText: String = "Loading..."

    @State private var pulse = false
    @State private var orbit = false

    var body: some View {
        ZStack {
            if (!loadingText.isEmpty) {
                Color.black
                    .opacity(0.34)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color.purple.opacity(0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 92, height: 92)
                            .scaleEffect(pulse ? 1.06 : 0.94)

                        Circle()
                            .stroke(Color.white.opacity(0.22), lineWidth: 1.2)
                            .frame(width: 112, height: 112)

                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: "sparkle")
                                .font(.system(size: 14 + CGFloat(index * 2), weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.92))
                                .offset(x: orbit ? 0 : 24)
                                .rotationEffect(.degrees(Double(index) * 120))
                                .rotationEffect(.degrees(orbit ? 360 : 0))
                        }

                        Image(systemName: "sparkles")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Text(loadingText)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .background(Color.black.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.purple.opacity(0.16), radius: 22, x: 0, y: 12)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                    withAnimation(.linear(duration: 5.5).repeatForever(autoreverses: false)) {
                        orbit = true
                    }
                }
            }
        }
    }
}
