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
        case 0.75..<1.0: return "Almost there 🌺"
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

            // Frame is 180 pt — tree is always fully drawn (ghost outline),
            // colours paint in progressively as goals are completed.
            TreeView(progress: appeared ? progress : 0)
                .frame(height: 180)
                .animation(.spring(response: 0.9, dampingFraction: 0.72), value: progress)

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

// MARK: - Tree canvas

struct TreeView: View {
    let progress: Double

    var body: some View {
        Canvas { ctx, size in
            let cx  = size.width / 2
            let bot = size.height - 8   // ground anchor (canvas y, increases downward)

            // ── Key tree points ────────────────────────────────────────────
            let trunkBase = CGPoint(x: cx, y: bot)
            let trunkTop  = CGPoint(x: cx, y: bot - 78)
            let lFork     = CGPoint(x: cx, y: bot - 50)   // lower branch fork
            let mFork     = CGPoint(x: cx, y: bot - 63)   // mid fork

            // Main branch tips
            let bl1  = CGPoint(x: cx - 60, y: bot - 76)
            let br1  = CGPoint(x: cx + 60, y: bot - 76)
            let bl2  = CGPoint(x: cx - 42, y: bot - 90)
            let br2  = CGPoint(x: cx + 42, y: bot - 90)
            let bl3  = CGPoint(x: cx - 18, y: bot - 97)
            let br3  = CGPoint(x: cx + 18, y: bot - 97)
            let bTop = CGPoint(x: cx,      y: bot - 116)

            // Sub-branch tips — these are the leaf / flower centres
            let sbl1a = CGPoint(x: cx - 78, y: bot - 95)
            let sbl1b = CGPoint(x: cx - 52, y: bot - 100)
            let sbr1a = CGPoint(x: cx + 78, y: bot - 95)
            let sbr1b = CGPoint(x: cx + 52, y: bot - 100)
            let sbl2a = CGPoint(x: cx - 57, y: bot - 113)
            let sbl2b = CGPoint(x: cx - 33, y: bot - 116)
            let sbr2a = CGPoint(x: cx + 57, y: bot - 113)
            let sbr2b = CGPoint(x: cx + 33, y: bot - 116)
            let sbl3  = CGPoint(x: cx - 27, y: bot - 122)
            let sbr3  = CGPoint(x: cx + 27, y: bot - 122)
            let sbta  = CGPoint(x: cx - 17, y: bot - 136)
            let sbtb  = CGPoint(x: cx + 17, y: bot - 136)

            // Leaf positions (all sub-branch tips)
            let leafPts: [CGPoint] = [
                sbl1a, sbl1b, sbr1a, sbr1b,
                sbl2a, sbl2b, sbr2a, sbr2b,
                sbl3,  sbr3,  sbta,  sbtb
            ]
            // Leaf colours (alternating two greens for depth)
            let leafColors: [Color] = [
                .appPlum, .appCoral, .appPlum, .appCoral,
                .appCoral, .appPlum, .appCoral, .appPlum,
                .appPlum,  .appPlum, .appCoral, .appCoral
            ]
            // Flower positions — the outermost/topmost clusters
            let flowerPts: [CGPoint] = [sbl1a, sbr1a, sbl2a, sbr2a, sbta, sbtb]

            // Line data as (from, to, lineWidth)
            let mainLines: [(CGPoint, CGPoint, CGFloat)] = [
                (lFork,    bl1,  7), (lFork,    br1,  7),
                (mFork,    bl2,  6), (mFork,    br2,  6),
                (trunkTop, bl3,  5), (trunkTop, br3,  5),
                (trunkTop, bTop, 5)
            ]
            let subLines: [(CGPoint, CGPoint, CGFloat)] = [
                (bl1,  sbl1a, 4),   (bl1,  sbl1b, 4),
                (br1,  sbr1a, 4),   (br1,  sbr1b, 4),
                (bl2,  sbl2a, 3.5), (bl2,  sbl2b, 3.5),
                (br2,  sbr2a, 3.5), (br2,  sbr2b, 3.5),
                (bl3,  sbl3,  3),   (br3,  sbr3,  3),
                (bTop, sbta,  3),   (bTop, sbtb,  3)
            ]

            // ── Progress alphas ────────────────────────────────────────────
            // Each stage fades in over its span window
            let tA  = stageAlpha(progress, start: 0.00, span: 0.22)  // trunk
            let bA  = stageAlpha(progress, start: 0.18, span: 0.28)  // branches
            let lA  = stageAlpha(progress, start: 0.44, span: 0.30)  // leaves
            let fA  = stageAlpha(progress, start: 0.72, span: 0.26)  // flowers

            let ghost    = Color(white: 0.84)                         // always-visible outline
            let brown    = Color(red: 0.40, green: 0.26, blue: 0.10) // trunk & branches
            let cream    = Color(red: 0.996, green: 0.996, blue: 0.890)

            // ── Pass 1: ghost — complete tree, light gray, always visible ──

            // Ground oval
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - 46, y: bot - 2, width: 92, height: 6)),
                with: .color(ghost)
            )

            // Trunk ghost (tapered: drawn as two overlapping strokes)
            treeStroke(&ctx, from: trunkBase, to: trunkTop, w: 16, color: ghost)
            treeStroke(&ctx, from: trunkBase, to: trunkTop, w: 10, color: ghost)

            // Root ghosts
            treeStroke(&ctx,
                from: CGPoint(x: cx - 4, y: bot - 2),
                to:   CGPoint(x: cx - 24, y: bot + 4), w: 7, color: ghost)
            treeStroke(&ctx,
                from: CGPoint(x: cx + 4, y: bot - 2),
                to:   CGPoint(x: cx + 24, y: bot + 4), w: 7, color: ghost)

            // Branch ghosts
            for (f, t, w) in mainLines + subLines {
                treeStroke(&ctx, from: f, to: t, w: w, color: ghost)
            }

            // Leaf cluster ghosts
            for pt in leafPts {
                ctx.fill(leafCluster(at: pt, r: 15), with: .color(ghost))
            }

            // Flower ghosts
            for pt in flowerPts {
                ctx.fill(flowerPetals(at: pt, petalR: 4.5, dist: 6.5), with: .color(ghost))
                ctx.fill(flowerCentre(at: pt), with: .color(ghost))
            }

            // ── Pass 2: colour — fills in progressively ────────────────────

            // Trunk coloured
            if tA > 0 {
                treeStroke(&ctx, from: trunkBase, to: trunkTop, w: 16, color: brown.opacity(tA))
                treeStroke(&ctx, from: trunkBase, to: trunkTop, w: 10, color: brown.opacity(tA * 0.7))
                treeStroke(&ctx,
                    from: CGPoint(x: cx - 4, y: bot - 2),
                    to:   CGPoint(x: cx - 24, y: bot + 4), w: 7, color: brown.opacity(tA))
                treeStroke(&ctx,
                    from: CGPoint(x: cx + 4, y: bot - 2),
                    to:   CGPoint(x: cx + 24, y: bot + 4), w: 7, color: brown.opacity(tA))
            }

            // Branches coloured
            if bA > 0 {
                for (f, t, w) in mainLines + subLines {
                    treeStroke(&ctx, from: f, to: t, w: w, color: brown.opacity(bA))
                }
            }

            // Leaves coloured
            if lA > 0 {
                for (i, pt) in leafPts.enumerated() {
                    ctx.fill(leafCluster(at: pt, r: 15),
                             with: .color(leafColors[i].opacity(lA)))
                }
                // A lighter highlight layer on each cluster
                for (i, pt) in leafPts.enumerated() {
                    ctx.fill(leafCluster(at: pt, r: 9),
                             with: .color(leafColors[i].mix(with: .white, by: 0.3).opacity(lA * 0.6)))
                }
            }

            // Flowers coloured
            if fA > 0 {
                for pt in flowerPts {
                    ctx.fill(flowerPetals(at: pt, petalR: 4.5, dist: 6.5),
                             with: .color(Color.appGold.opacity(fA)))
                    ctx.fill(flowerCentre(at: pt),
                             with: .color(cream.opacity(fA)))
                }
            }
        }
    }
}

// MARK: - Canvas helpers (file-private, no inout capture needed)

/// Stroke a line segment with round caps.
private func treeStroke(
    _ ctx: inout GraphicsContext,
    from: CGPoint, to: CGPoint,
    w: CGFloat, color: Color
) {
    var p = Path()
    p.move(to: from)
    p.addLine(to: to)
    ctx.stroke(p, with: .color(color),
               style: StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
}

/// Three overlapping ellipses give an organic leaf-cluster silhouette.
private func leafCluster(at centre: CGPoint, r: CGFloat) -> Path {
    var p = Path()
    // Wide horizontal blob
    p.addEllipse(in: CGRect(x: centre.x - r,       y: centre.y - r * 0.65,
                            width: r * 2,           height: r * 1.30))
    // Tall vertical blob (upper portion)
    p.addEllipse(in: CGRect(x: centre.x - r * 0.75, y: centre.y - r * 1.25,
                            width: r * 1.50,         height: r * 1.50))
    // Lower filler blob
    p.addEllipse(in: CGRect(x: centre.x - r * 0.60, y: centre.y - r * 0.20,
                            width: r * 1.20,         height: r * 0.90))
    return p
}

/// Five petal circles arranged in a ring.
private func flowerPetals(at centre: CGPoint, petalR: CGFloat, dist: CGFloat) -> Path {
    var p = Path()
    for i in 0..<5 {
        let angle = Double(i) * 72.0 * .pi / 180.0 - .pi / 2
        let px = centre.x + CGFloat(cos(angle)) * dist
        let py = centre.y + CGFloat(sin(angle)) * dist
        p.addEllipse(in: CGRect(x: px - petalR, y: py - petalR,
                                width: petalR * 2, height: petalR * 2))
    }
    return p
}

/// Small circle for the flower centre.
private func flowerCentre(at centre: CGPoint) -> Path {
    Path(ellipseIn: CGRect(x: centre.x - 3, y: centre.y - 3, width: 6, height: 6))
}

/// Clamp progress into a 0…1 alpha for a given stage window.
private func stageAlpha(_ progress: Double, start: Double, span: Double) -> Double {
    max(0, min((progress - start) / span, 1))
}
