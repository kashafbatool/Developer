//
//  EnergyCheckInView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI

struct EnergyCheckInView: View {
    @Binding var showCheckIn: Bool
    let userProgress: UserProgress

    @State private var selectedLevel: Int? = nil
    @State private var quote: String = ""

    let levels: [(emoji: String, label: String)] = [
        ("😔", "Struggling"),
        ("😐", "Low"),
        ("🙂", "Okay"),
        ("😊", "Good"),
        ("🔥", "Amazing")
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if let level = selectedLevel {
                quotePhase(level: level)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))
            } else {
                selectionPhase
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: selectedLevel)
    }

    // MARK: - Phase 1: energy selection

    private var selectionPhase: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 12) {
                Text("DAILY CHECK-IN")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextSecondary)
                    .tracking(2)

                Text("How are you\nfeeling today?")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.appPlum)
                    .multilineTextAlignment(.center)

                Text("Your dashboard will adapt to support you")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }

            HStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { i in
                    Button {
                        userProgress.recordCheckIn(energyLevel: i + 1)
                        quote = Quotes.forLevel(i + 1).randomElement() ?? ""
                        selectedLevel = i + 1
                    } label: {
                        VStack(spacing: 8) {
                            Text(levels[i].emoji)
                                .font(.system(size: 30))
                            Text(levels[i].label)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color.appPlum.opacity(0.06), radius: 8, y: 3)
                    }
                }
            }
            .padding(.horizontal)

            Button("Skip for now") {
                showCheckIn = false
            }
            .font(.subheadline)
            .foregroundStyle(Color.appTextSecondary)

            Spacer()
        }
    }

    // MARK: - Phase 2: motivational quote

    @ViewBuilder
    private func quotePhase(level: Int) -> some View {
        VStack(spacing: 36) {
            Spacer()

            Text(levels[level - 1].emoji)
                .font(.system(size: 72))

            VStack(spacing: 14) {
                Text("A little something for you")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appTextSecondary)
                    .tracking(1.5)

                // Split "Quote text. — Author" for styling
                let parts = quote.components(separatedBy: " — ")
                VStack(spacing: 8) {
                    Text(parts.first ?? quote)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appPlum)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    if parts.count > 1 {
                        Text("— \(parts[1])")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .padding(.horizontal, 28)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCheckIn = false
                }
            } label: {
                Text("Let's go ✨")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appPlum)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}
