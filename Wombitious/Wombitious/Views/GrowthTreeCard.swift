//
//  GrowthTreeCard.swift
//  SheRise
//

import SwiftUI

// MARK: - Card

struct GrowthTreeCard: View {
    let goals: [Goal]
    let confidenceScore: Int
    @State private var appeared = false

    private var allTargets: [MicroTarget] { goals.filter { !$0.isCompleted }.flatMap { $0.microTargets } }
    private var completedCount: Int { allTargets.filter { $0.isCompleted }.count }
    private var totalCount: Int { allTargets.count }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var stageLabel: String {
        switch progress {
        case 0:          return "Plant your seed"
        case 0..<0.25:   return "Sprouting 🌱"
        case 0.25..<0.5: return "Growing 🌿"
        case 0.5..<0.75: return "Thriving 🌳"
        case 0.75..<1.0: return "Almost there 🌲"
        default:         return "In Full Bloom 🌸"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("YOUR GROWTH")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appGold)
                    .tracking(1.5)
                Spacer()
                Text(stageLabel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appPlum)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.appPlum.opacity(0.08))
                    .clipShape(Capsule())
            }

            TreeView(progress: appeared ? progress : 0)
                .frame(height: 130)

            HStack {
                statPill(value: "\(confidenceScore)", label: "confidence")
                Spacer()
                if totalCount > 0 {
                    statPill(value: "\(completedCount)/\(totalCount)", label: "steps done", trailing: true)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.08), radius: 12, y: 4)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.75).delay(0.2)) {
                appeared = true
            }
        }
        .onChange(of: completedCount) { _, _ in
            // Pulse when a new step is completed
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) { }
        }
    }

    @ViewBuilder
    private func statPill(value: String, label: String, trailing: Bool = false) -> some View {
        VStack(alignment: trailing ? .trailing : .leading, spacing: 1) {
            Text(value)
                .font(.title3).fontWeight(.bold).foregroundStyle(Color.appPlum)
            Text(label)
                .font(.caption2).foregroundStyle(Color.appTextSecondary)
        }
    }
}

// MARK: - Tree drawing

struct TreeView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2
            let h  = geo.size.height
            let bottom = h - 6

            ZStack {
                // Ground
                Capsule()
                    .fill(Color.appPlum.opacity(0.10))
                    .frame(width: 80, height: 5)
                    .position(x: cx, y: bottom)

                // Trunk
                if progress > 0 {
                    let trunkH = h * 0.42 * min(progress * 5, 1)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.40, green: 0.26, blue: 0.10))
                        .frame(width: 10, height: trunkH)
                        .position(x: cx, y: bottom - trunkH / 2)
                        .animation(.spring(response: 0.9, dampingFraction: 0.7), value: progress)
                }

                // Lower branches + leaves  (25%+)
                if progress > 0.20 {
                    let s = min((progress - 0.20) / 0.25, 1.0)
                    let branchY = bottom - h * 0.42 * 0.65
                    branch(cx: cx, y: branchY, angleDeg: -140, len: 34 * s)
                    branch(cx: cx, y: branchY, angleDeg: -40,  len: 34 * s)

                    if s > 0.3 {
                        let ls = min((s - 0.3) / 0.7, 1.0)
                        leafCluster(color: Color.appCoral, size: 36 * ls)
                            .position(x: cx - 32, y: branchY - 14 * ls)
                        leafCluster(color: Color.appPlum, size: 36 * ls)
                            .position(x: cx + 32, y: branchY - 14 * ls)
                    }
                }

                // Mid branches + leaves  (50%+)
                if progress > 0.45 {
                    let s = min((progress - 0.45) / 0.25, 1.0)
                    let topY = bottom - h * 0.42
                    branch(cx: cx, y: topY + 6, angleDeg: -155, len: 26 * s)
                    branch(cx: cx, y: topY + 6, angleDeg: -25,  len: 26 * s)

                    if s > 0.4 {
                        let ls = min((s - 0.4) / 0.6, 1.0)
                        leafCluster(color: Color.appPlum, size: 30 * ls)
                            .position(x: cx - 24, y: topY - 10 * ls)
                        leafCluster(color: Color.appCoral, size: 30 * ls)
                            .position(x: cx + 24, y: topY - 10 * ls)
                    }
                }

                // Crown canopy  (70%+)
                if progress > 0.65 {
                    let s = min((progress - 0.65) / 0.25, 1.0)
                    let topY = bottom - h * 0.42
                    leafCluster(color: Color.appPlum, size: 48 * s, dense: true)
                        .position(x: cx, y: topY - 22 * s)
                }

                // Full bloom sparkles  (100%)
                if progress >= 1.0 {
                    let topY = bottom - h * 0.42
                    Text("🌸").font(.caption).position(x: cx - 28, y: topY - 34)
                    Text("✨").font(.caption2).position(x: cx + 30, y: topY - 28)
                    Text("🌸").font(.caption2).position(x: cx + 8,  y: topY - 48)
                }
            }
        }
    }

    // A single branch drawn as a rotated capsule
    @ViewBuilder
    private func branch(cx: CGFloat, y: CGFloat, angleDeg: Double, len: Double) -> some View {
        let rad = angleDeg * .pi / 180
        let endX = cx + CGFloat(cos(rad)) * len
        let endY = y  + CGFloat(sin(rad)) * len
        let midX = (cx + endX) / 2
        let midY = (y  + endY) / 2
        let dist = sqrt(pow(endX - cx, 2) + pow(endY - y, 2))

        Capsule()
            .fill(Color(red: 0.40, green: 0.26, blue: 0.10))
            .frame(width: dist, height: 5)
            .rotationEffect(.radians(atan2(endY - y, endX - cx)))
            .position(x: midX, y: midY)
            .animation(.spring(response: 0.7, dampingFraction: 0.7), value: len)
    }

    // A cluster of overlapping ellipses
    @ViewBuilder
    private func leafCluster(color: Color, size: Double, dense: Bool = false) -> some View {
        let s = max(0, size)
        ZStack {
            Ellipse()
                .fill(color.opacity(0.82))
                .frame(width: s * 0.90, height: s * 0.70)
                .offset(x: -s * 0.12)
            Ellipse()
                .fill(color.opacity(0.70))
                .frame(width: s * 0.72, height: s * 0.88)
                .offset(x: s * 0.18, y: -s * 0.08)
            if dense {
                Ellipse()
                    .fill(color.opacity(0.60))
                    .frame(width: s * 0.55, height: s * 0.55)
                    .offset(y: -s * 0.22)
                Ellipse()
                    .fill(Color.appGold.opacity(0.25))
                    .frame(width: s * 0.40, height: s * 0.40)
                    .offset(x: -s * 0.05, y: s * 0.10)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.65), value: s)
    }
}
