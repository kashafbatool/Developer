//
//  SheRiseIntroView.swift
//  sheRise
//

import SwiftUI

// MARK: - Intro Animation View

struct SheRiseIntroView: View {
    var onComplete: () -> Void

    // ── Figure pose — changes drive Canvas re-draws via withAnimation ──────
    @State private var bodyTilt:   Double  = 0      // + = clockwise / lean forward
    @State private var lArmAngle:  Double  = 18     // from body-down axis, + = outward
    @State private var rArmAngle:  Double  = -18
    @State private var lLegAngle:  Double  = -10
    @State private var rLegAngle:  Double  = 10
    @State private var figureY:    CGFloat = 0
    @State private var figureFlip: CGFloat = 1      // 1 = right, -1 = facing viewer

    // ── Glowing seed ──────────────────────────────────────────────────────
    @State private var dotVisible = false
    @State private var dotAlpha:  Double  = 0
    @State private var dotX:      CGFloat = 40
    @State private var dotY:      CGFloat = 60

    // ── Hand glow ─────────────────────────────────────────────────────────
    @State private var glowAlpha:  Double  = 0
    @State private var glowRadius: CGFloat = 12

    // ── Logo ──────────────────────────────────────────────────────────────
    @State private var logoOpacity: Double  = 0
    @State private var logoScale:   CGFloat = 0.22
    @State private var logoY:       CGFloat = -40

    // ── Screen fade ───────────────────────────────────────────────────────
    @State private var fadeAlpha: Double = 0

    // Drawing constants
    private let headR:  CGFloat = 13
    private let torsoH: CGFloat = 36
    private let armLen: CGFloat = 26
    private let legLen: CGFloat = 30
    private let lw:     CGFloat = 3.2
    private let sX:     CGFloat = 10
    private let hX:     CGFloat = 9

    // MARK: Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            // Ground line
            Capsule()
                .fill(Color.appPlum.opacity(0.10))
                .frame(width: 200, height: 2)
                .offset(y: figureY + 60)

            // Glowing seed on the ground
            if dotVisible {
                ZStack {
                    Circle()
                        .fill(Color.appGold.opacity(0.30))
                        .frame(width: 24, height: 24)
                        .blur(radius: 7)
                    Circle()
                        .fill(Color.appGold)
                        .frame(width: 10, height: 10)
                }
                .opacity(dotAlpha)
                .offset(x: dotX * figureFlip, y: figureY + dotY)
            }

            // Stick figure
            // Canvas re-renders each animation frame because the @State vars
            // that drive it are interpolated by withAnimation on every frame.
            Canvas { ctx, size in
                var c = ctx
                // Hip is the rotation pivot, placed at 58 % down the canvas
                c.translateBy(x: size.width / 2, y: size.height * 0.58)
                c.rotate(by: .degrees(bodyTilt))
                renderFigure(in: &c)
            }
            .frame(width: 220, height: 240)
            .offset(y: figureY)
            .scaleEffect(x: figureFlip, y: 1)

            // Glow at raised-arm tip
            // When rArmAngle ≈ 168° and bodyTilt = 0 the right-arm tip sits
            // ~15 px from centre-x and ~40 px above the canvas hip point.
            Circle()
                .fill(Color.appGold.opacity(0.65))
                .frame(width: glowRadius * 2, height: glowRadius * 2)
                .blur(radius: glowRadius * 0.55)
                .opacity(glowAlpha)
                .offset(x: figureFlip * 15, y: figureY - 40)

            // sheRise logo
            HStack(spacing: 0) {
                Text("she")
                    .font(.system(size: 52, weight: .light, design: .serif))
                    .foregroundColor(Color.appCoral)
                Text("Rise")
                    .font(.system(size: 52, weight: .bold, design: .serif))
                    .foregroundColor(Color.appPlum)
            }
            .scaleEffect(logoScale)
            .offset(y: logoY)
            .opacity(logoOpacity)

            // Fade overlay — dark to match AuthView's gradient start colour
            Color(red: 0.07, green: 0.04, blue: 0.13)
                .ignoresSafeArea()
                .opacity(fadeAlpha)
        }
        .onAppear {
            Task { @MainActor in await playIntro() }
        }
    }

    // MARK: Canvas drawing

    private func renderFigure(in ctx: inout GraphicsContext) {
        let col = GraphicsContext.Shading.color(Color.appPlum)

        func line(from a: CGPoint, to b: CGPoint) {
            var p = Path()
            p.move(to: a); p.addLine(to: b)
            ctx.stroke(p, with: col,
                       style: StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round))
        }

        // angle 0° → limb straight down; +° → swings to its own side; side ±1
        func tip(from o: CGPoint, angle: Double, length: CGFloat, side: CGFloat) -> CGPoint {
            let r = angle * .pi / 180
            return CGPoint(x: o.x + side * sin(r) * length,
                           y: o.y + cos(r) * length)
        }

        // Head
        let hc = CGPoint(x: 0, y: -(torsoH + 5 + headR))
        ctx.fill(Path(ellipseIn: CGRect(x: hc.x - headR, y: hc.y - headR,
                                        width: headR * 2, height: headR * 2)), with: col)
        // Spine
        line(from: CGPoint(x: 0, y: -(torsoH + 5)), to: CGPoint(x: 0, y: 0))
        // Arms
        let ls = CGPoint(x: -sX, y: -(torsoH - 4))
        let rs = CGPoint(x:  sX, y: -(torsoH - 4))
        line(from: ls, to: tip(from: ls, angle: lArmAngle, length: armLen, side: -1))
        line(from: rs, to: tip(from: rs, angle: rArmAngle, length: armLen, side:  1))
        // Legs
        let lh = CGPoint(x: -hX, y: 0)
        let rh = CGPoint(x:  hX, y: 0)
        line(from: lh, to: tip(from: lh, angle: lLegAngle, length: legLen, side: -1))
        line(from: rh, to: tip(from: rh, angle: rLegAngle, length: legLen, side:  1))
    }

    // MARK: Animation — total ≤ 4 s

    @MainActor
    private func playIntro() async {
        func sleep(_ ms: Double) async {
            try? await Task.sleep(nanoseconds: UInt64(ms * 1_000_000))
        }
        func ease(_ dur: Double, _ block: () -> Void) async {
            withAnimation(.easeInOut(duration: dur), block)
            await sleep(dur * 1_000)
        }
        func spring(_ dur: Double, _ block: () -> Void) async {
            withAnimation(.spring(duration: dur, bounce: 0.25), block)
            await sleep(dur * 1_000)
        }

        // 1 · Run (one stride, ~0.45 s) ─────────────────────────────────────
        await ease(0.16) {
            lArmAngle = -50; rArmAngle = 50; lLegAngle = 36; rLegAngle = -36; figureY = -4
        }
        await ease(0.16) {
            lArmAngle = 50; rArmAngle = -50; lLegAngle = -36; rLegAngle = 36; figureY = 4
        }
        await ease(0.13) {
            lArmAngle = 18; rArmAngle = -18; lLegAngle = -10; rLegAngle = 10; figureY = 0
        }

        // 2 · Fall (~0.35 s) ─────────────────────────────────────────────────
        await ease(0.20) {
            bodyTilt = 62; lArmAngle = 105; rArmAngle = 92; figureY = 14
        }
        await ease(0.10) {
            bodyTilt = 80; lArmAngle = 130; rArmAngle = 122; figureY = 18
        }
        await sleep(250)        // brief pause on the ground

        // 3 · Rise (~0.55 s) ─────────────────────────────────────────────────
        await ease(0.22) { bodyTilt = 38; lArmAngle = 55; rArmAngle = 48; figureY = 10 }
        await spring(0.33) {
            bodyTilt = 0; lArmAngle = 18; rArmAngle = -18; lLegAngle = -10; rLegAngle = 10; figureY = 0
        }
        await sleep(120)

        // 4 · Notice seed, pick it up, stand (~0.70 s) ───────────────────────
        dotVisible = true
        withAnimation(.easeIn(duration: 0.20)) { dotAlpha = 1 }
        await ease(0.22) { bodyTilt = 40; rArmAngle = 112; dotX = 18; dotY = 18 }
        await ease(0.16) { dotX = 4; dotY = -8 }           // dot flies to hand
        await spring(0.32) {
            bodyTilt = 0; lArmAngle = 18; rArmAngle = -18; lLegAngle = -10; rLegAngle = 10
        }
        withAnimation(.easeOut(duration: 0.16)) { dotAlpha = 0 }
        await sleep(150)

        // 5 · Turn to face viewer (~0.22 s) ───────────────────────────────────
        await ease(0.22) { figureFlip = -1 }
        await sleep(80)

        // 6 · Raise arm + glow (~0.55 s) ──────────────────────────────────────
        await ease(0.30) { rArmAngle = 168; lArmAngle = -26 }
        await ease(0.25) { glowAlpha = 1; glowRadius = 48 }
        await sleep(80)

        // 7 · Logo emerges (~0.50 s) ──────────────────────────────────────────
        logoY = -40
        await ease(0.50) { logoOpacity = 1; logoScale = 0.85; logoY = -52 }
        await sleep(100)

        // 8 · Logo expands to centre (~0.45 s) ────────────────────────────────
        await ease(0.45) { logoScale = 1.25; logoY = -28; glowAlpha = 0 }
        await sleep(200)

        // 9 · Fade to dark, reveal login (~0.55 s) ────────────────────────────
        await ease(0.55) { fadeAlpha = 1 }
        await sleep(120)

        onComplete()
    }
}

#Preview {
    SheRiseIntroView { }
}
