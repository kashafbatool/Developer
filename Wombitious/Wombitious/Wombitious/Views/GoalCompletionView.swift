//
//  GoalCompletionView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI

struct GoalCompletionView: View {
    let goal: Goal
    let userProgress: UserProgress
    let onDismiss: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            Color.appPlum.ignoresSafeArea()

            if animate {
                CelebrationConfetti()
            }

            VStack(spacing: 0) {
                Spacer()

                // Trophy
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 160, height: 160)
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: 110, height: 110)
                    Text("🏆")
                        .font(.system(size: 64))
                        .scaleEffect(animate ? 1.15 : 0.4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55), value: animate)
                }

                Spacer().frame(height: 32)

                VStack(spacing: 10) {
                    Text("Goal Complete!")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)

                    Text(goal.title)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer().frame(height: 32)

                // Stats row
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

                Spacer().frame(height: 16)

                // Rank badge if they levelled up
                Text("You're a \(userProgress.rank) now")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGold)
                    .fontWeight(.medium)

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
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animate = true
            }
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

// MARK: - Celebration confetti (bigger than row confetti)
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
