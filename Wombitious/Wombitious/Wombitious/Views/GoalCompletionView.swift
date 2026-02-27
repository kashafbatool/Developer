//
//  GoalCompletionView.swift
//  SheRise
//
//  Created by Kashaf Batool
//

import SwiftUI

// Phases for the trophy PhaseAnimator
private enum TrophyPhase: CaseIterable {
    case hidden, pop, settle, glow
}

struct GoalCompletionView: View {
    let goal: Goal
    let userProgress: UserProgress
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var hapticTrigger = false

    var body: some View {
        ZStack {
            Color.appPlum.ignoresSafeArea()

            CelebrationConfetti()

            VStack(spacing: 0) {
                Spacer()

                // Animated trophy using PhaseAnimator
                PhaseAnimator(TrophyPhase.allCases, trigger: showContent) { phase in
                    ZStack {
                        Circle()
                            .fill(.white.opacity(glowOpacity(phase)))
                            .frame(width: 180, height: 180)
                            .blur(radius: phase == .glow ? 12 : 0)

                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 160, height: 160)

                        Circle()
                            .fill(.white.opacity(0.05))
                            .frame(width: 110, height: 110)

                        Text("🏆")
                            .font(.system(size: 64))
                            .scaleEffect(trophyScale(phase))
                            .rotationEffect(.degrees(trophyRotation(phase)))
                    }
                } animation: { phase in
                    switch phase {
                    case .hidden:  return .easeIn(duration: 0.01)
                    case .pop:     return .spring(response: 0.45, dampingFraction: 0.5)
                    case .settle:  return .spring(response: 0.3, dampingFraction: 0.7)
                    case .glow:    return .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                    }
                }

                Spacer().frame(height: 32)

                VStack(spacing: 10) {
                    Text("Goal Complete!")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.5).delay(0.3), value: showContent)

                    Text(goal.title)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.5).delay(0.45), value: showContent)
                }

                Spacer().frame(height: 32)

                HStack(spacing: 0) {
                    completionStat(value: "\(goal.microTargets.count)", label: "Steps done")
                    Divider()
                        .frame(height: 36)
                        .background(.white.opacity(0.25))
                    completionStat(value: "\(goal.timelineMonths)mo", label: "Timeline")
                    Divider()
                        .frame(height: 36)
                        .background(.white.opacity(0.25))
                    completionStat(value: "+\(goal.microTargets.count * 10)", label: "Points earned")
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 24)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.5).delay(0.55), value: showContent)

                Spacer().frame(height: 16)

                Text("You're a \(userProgress.rank) now")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGold)
                    .fontWeight(.medium)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeIn.delay(0.65), value: showContent)

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Text("Keep Going")
                        .font(.headline)
                        .foregroundStyle(Color.appPlum)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("Dismiss goal completion and continue")
                .sensoryFeedback(.success, trigger: hapticTrigger)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn.delay(0.7), value: showContent)
            }
        }
        .onAppear {
            showContent = true
            hapticTrigger.toggle()
        }
    }

    // MARK: - PhaseAnimator helpers
    private func trophyScale(_ phase: TrophyPhase) -> CGFloat {
        switch phase {
        case .hidden: return 0.3
        case .pop:    return 1.25
        case .settle: return 1.0
        case .glow:   return 1.05
        }
    }

    private func trophyRotation(_ phase: TrophyPhase) -> Double {
        switch phase {
        case .hidden: return -15
        case .pop:    return 8
        case .settle: return 0
        case .glow:   return 0
        }
    }

    private func glowOpacity(_ phase: TrophyPhase) -> Double {
        switch phase {
        case .glow: return 0.12
        default:    return 0
        }
    }

    @ViewBuilder
    func completionStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.appGold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Celebration confetti
struct CelebrationConfetti: View {
    @State private var animate = false
    let colors: [Color] = [.white, Color.appGold, Color.appCoral, .yellow, .green, .pink, .cyan]

    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { i in
                let angle = Double(i) / 50.0 * 2 * .pi
                let dist = CGFloat([100, 150, 200, 250, 180, 220, 130][i % 7])

                RoundedRectangle(cornerRadius: 2)
                    .fill(colors[i % colors.count])
                    .frame(width: 10, height: 6)
                    .offset(
                        x: animate ? CGFloat(cos(angle)) * dist : 0,
                        y: animate ? CGFloat(sin(angle)) * dist - 40 : 0
                    )
                    .rotationEffect(.degrees(animate ? Double(i * 43) : 0))
                    .opacity(animate ? 0 : 0.9)
                    .animation(.easeOut(duration: 1.4).delay(Double(i) * 0.012), value: animate)
            }
        }
        .onAppear { animate = true }
        .allowsHitTesting(false)
    }
}
