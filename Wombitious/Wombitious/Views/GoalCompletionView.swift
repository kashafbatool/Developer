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

                // Stick figure victory animation
                VictoryFigureView()
                    .frame(width: 120, height: 120)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.1), value: showContent)

                Spacer().frame(height: 8)

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

// MARK: - Victory stick figure

struct VictoryFigureView: View {
    private let headR:  CGFloat = 9
    private let torsoH: CGFloat = 26
    private let armLen: CGFloat = 20
    private let legLen: CGFloat = 22
    private let lw:     CGFloat = 2.8
    private let sX:     CGFloat = 7
    private let hX:     CGFloat = 6

    @State private var lArmAngle: Double = 18
    @State private var rArmAngle: Double = -18
    @State private var lLegAngle: Double = -10
    @State private var rLegAngle: Double = 10
    @State private var figureY:   CGFloat = 0

    var body: some View {
        Canvas { ctx, size in
            // Directly reference state vars so Canvas re-renders on each animation frame
            let la = lArmAngle, ra = rArmAngle, ll = lLegAngle, rl = rLegAngle
            var c = ctx
            c.translateBy(x: size.width / 2, y: size.height * 0.62)

            let col = GraphicsContext.Shading.color(Color.white)

            func line(from a: CGPoint, to b: CGPoint) {
                var p = Path(); p.move(to: a); p.addLine(to: b)
                c.stroke(p, with: col,
                         style: StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round))
            }

            func tip(from o: CGPoint, angle: Double, length: CGFloat, side: CGFloat) -> CGPoint {
                let r = angle * .pi / 180
                return CGPoint(x: o.x + side * sin(r) * length, y: o.y + cos(r) * length)
            }

            // Head
            let hc = CGPoint(x: 0, y: -(torsoH + 5 + headR))
            c.fill(Path(ellipseIn: CGRect(x: hc.x - headR, y: hc.y - headR,
                                          width: headR * 2, height: headR * 2)), with: col)
            // Spine
            line(from: CGPoint(x: 0, y: -(torsoH + 5)), to: .zero)
            // Arms
            let ls = CGPoint(x: -sX, y: -(torsoH - 3))
            let rs = CGPoint(x:  sX, y: -(torsoH - 3))
            line(from: ls, to: tip(from: ls, angle: la, length: armLen, side: -1))
            line(from: rs, to: tip(from: rs, angle: ra, length: armLen, side:  1))
            // Legs
            let lh = CGPoint(x: -hX, y: 0)
            let rh = CGPoint(x:  hX, y: 0)
            line(from: lh, to: tip(from: lh, angle: ll, length: legLen, side: -1))
            line(from: rh, to: tip(from: rh, angle: rl, length: legLen, side:  1))
        }
        .offset(y: figureY)
        .onAppear { runVictory() }
    }

    private func runVictory() {
        // Jump up with legs spread
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.2)) {
            figureY = -14; lLegAngle = -30; rLegAngle = 30
        }
        // Arms shoot up
        withAnimation(.spring(response: 0.35, dampingFraction: 0.5).delay(0.25)) {
            lArmAngle = 155; rArmAngle = -155
        }
        // Land and settle, legs back down
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.55)) {
            figureY = 0; lLegAngle = -10; rLegAngle = 10
        }
        // Arms sway gently in victory pose
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.0)) {
            lArmAngle = 148; rArmAngle = -148
        }
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
