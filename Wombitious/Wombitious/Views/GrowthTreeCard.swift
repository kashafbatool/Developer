//
//  GrowthTreeCard.swift
//  SheRise
//

import SwiftUI

// MARK: - Card

struct GrowthTreeCard: View {
    let goals: [Goal]
    let confidenceScore: Int

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

            TreeView(progress: progress)
                .frame(height: 220)

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
    let progress: Double   // kept for API compatibility

    private let trunkColor  = Color(red: 0.38, green: 0.24, blue: 0.09)
    private let branchColor = Color(red: 0.50, green: 0.33, blue: 0.13)
    private let twigColor   = Color(red: 0.62, green: 0.42, blue: 0.18)

    var body: some View {
        GeometryReader { geo in
            let cx     = geo.size.width / 2
            let h      = geo.size.height
            let bottom = h - 8
            let fullH  = h * 0.58
            let b1Y    = bottom - fullH * 0.52   // lower main branch level
            let b2Y    = bottom - fullH * 0.76   // upper main branch level
            let topY   = bottom - fullH          // tip of trunk

            ZStack {
                // ── Ground shadow ──────────────────────────────────────────
                Ellipse()
                    .fill(Color.appPlum.opacity(0.07))
                    .frame(width: 100, height: 10)
                    .position(x: cx, y: bottom + 4)

                // ── Trunk (tapered: 16px base → 9px top) ──────────────────
                TaperedTrunk(bottomWidth: 16, topWidth: 9)
                    .fill(trunkColor)
                    .frame(width: 16, height: fullH)
                    .position(x: cx, y: bottom - fullH / 2)

                // ── Lower main branches ────────────────────────────────────
                bough(cx: cx, y: b1Y, deg: -142, len: 42, color: branchColor, thick: 5.5)
                bough(cx: cx, y: b1Y, deg:  -38, len: 42, color: branchColor, thick: 5.5)

                // Lower secondary (left)
                bough(cx: cx, y: b1Y,     deg: -164, len: 24, color: branchColor, thick: 3.5)
                bough(cx: cx, y: b1Y,     deg: -122, len: 19, color: branchColor, thick: 3.5)
                // Lower secondary (right)
                bough(cx: cx, y: b1Y,     deg:  -58, len: 19, color: branchColor, thick: 3.5)
                bough(cx: cx, y: b1Y,     deg:  -16, len: 24, color: branchColor, thick: 3.5)

                // Lower twigs (left)
                bough(cx: cx, y: b1Y - 5, deg: -174, len: 12, color: twigColor, thick: 2)
                bough(cx: cx, y: b1Y - 5, deg: -150, len: 10, color: twigColor, thick: 2)
                bough(cx: cx, y: b1Y - 5, deg: -110, len: 10, color: twigColor, thick: 2)
                // Lower twigs (right)
                bough(cx: cx, y: b1Y - 5, deg:  -70, len: 10, color: twigColor, thick: 2)
                bough(cx: cx, y: b1Y - 5, deg:  -30, len: 10, color: twigColor, thick: 2)
                bough(cx: cx, y: b1Y - 5, deg:   -6, len: 12, color: twigColor, thick: 2)

                // ── Upper main branches ────────────────────────────────────
                bough(cx: cx, y: b2Y, deg: -157, len: 32, color: branchColor, thick: 4)
                bough(cx: cx, y: b2Y, deg:  -23, len: 32, color: branchColor, thick: 4)

                // Upper secondary (left)
                bough(cx: cx, y: b2Y,     deg: -174, len: 18, color: branchColor, thick: 2.5)
                bough(cx: cx, y: b2Y,     deg: -138, len: 14, color: branchColor, thick: 2.5)
                // Upper secondary (right)
                bough(cx: cx, y: b2Y,     deg:  -42, len: 14, color: branchColor, thick: 2.5)
                bough(cx: cx, y: b2Y,     deg:   -6, len: 18, color: branchColor, thick: 2.5)

                // Upper twigs
                bough(cx: cx, y: b2Y - 4, deg: -162, len: 10, color: twigColor, thick: 1.8)
                bough(cx: cx, y: b2Y - 4, deg: -128, len:  9, color: twigColor, thick: 1.8)
                bough(cx: cx, y: b2Y - 4, deg:  -52, len:  9, color: twigColor, thick: 1.8)
                bough(cx: cx, y: b2Y - 4, deg:  -18, len: 10, color: twigColor, thick: 1.8)

                // ── Crown branches ─────────────────────────────────────────
                bough(cx: cx, y: topY + 10, deg:  -90, len: 22, color: branchColor, thick: 3.5)
                bough(cx: cx, y: topY + 10, deg: -118, len: 16, color: branchColor, thick: 3)
                bough(cx: cx, y: topY + 10, deg:  -62, len: 16, color: branchColor, thick: 3)

                // Crown twigs
                bough(cx: cx, y: topY + 4, deg:  -90, len: 13, color: twigColor, thick: 1.8)
                bough(cx: cx, y: topY + 4, deg: -120, len: 10, color: twigColor, thick: 1.5)
                bough(cx: cx, y: topY + 4, deg:  -60, len: 10, color: twigColor, thick: 1.5)
                bough(cx: cx, y: topY,     deg: -136, len:  8, color: twigColor, thick: 1.2)
                bough(cx: cx, y: topY,     deg:  -44, len:  8, color: twigColor, thick: 1.2)
                bough(cx: cx, y: topY - 2, deg:  -90, len:  9, color: twigColor, thick: 1.2)
            }
        }
    }

    @ViewBuilder
    private func bough(cx: CGFloat, y: CGFloat, deg: Double, len: Double, color: Color, thick: CGFloat) -> some View {
        let rad  = deg * .pi / 180
        let endX = cx + CGFloat(cos(rad)) * len
        let endY = y  + CGFloat(sin(rad)) * len
        let midX = (cx + endX) / 2
        let midY = (y  + endY) / 2
        let dist = sqrt(pow(endX - cx, 2) + pow(endY - y, 2))
        Capsule()
            .fill(color)
            .frame(width: dist, height: thick)
            .rotationEffect(.radians(atan2(endY - y, endX - cx)))
            .position(x: midX, y: midY)
    }
}

// MARK: - Tapered trunk shape

private struct TaperedTrunk: Shape {
    let bottomWidth: CGFloat
    let topWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        var p = Path()
        p.move(to: CGPoint(x: cx - bottomWidth / 2, y: rect.maxY))
        p.addLine(to: CGPoint(x: cx - topWidth / 2,    y: rect.minY))
        p.addLine(to: CGPoint(x: cx + topWidth / 2,    y: rect.minY))
        p.addLine(to: CGPoint(x: cx + bottomWidth / 2, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
