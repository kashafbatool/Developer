//
//  SheRiseIntroView.swift
//  sheRise
//

import SwiftUI

struct SheRiseIntroView: View {
    var onComplete: () -> Void

    @State private var logoOpacity: Double  = 0
    @State private var logoScale:   CGFloat = 0.22
    @State private var logoY:       CGFloat = -160

    // ── Quote ─────────────────────────────────────────────────────────────
    @State private var quoteText:    String = ""
    @State private var quoteOpacity: Double = 0

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
            Image("SheRiseLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 240)
                .scaleEffect(logoScale)
                .offset(y: logoY)
                .opacity(logoOpacity)

            // Motivational quote — fades in with logo
            if !quoteText.isEmpty {
                Text(quoteText)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appPlum.opacity(0.80))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 10)
                    .background(Color.appPlum.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .offset(y: 120)
                    .opacity(quoteOpacity)
            }

            // Fade overlay — dark to match AuthView's gradient start colour
            Color.appDark
                .ignoresSafeArea()
                .opacity(fadeAlpha)
        }
        .onAppear {
            Task { @MainActor in await playIntro() }
        }
    }

    // MARK: Animation — total ≈ 3 s

    @MainActor
    private func playIntro() async {
        func sleep(_ ms: Double) async {
            try? await Task.sleep(nanoseconds: UInt64(ms * 1_000_000))
        }

        // 1 · Logo fades + scales in (~0.7 s)
        withAnimation(.easeOut(duration: 0.7)) {
            logoOpacity = 1
            logoScale   = 1.0
        }
        await sleep(700 + 900)   // animation + hold

        // 2 · Gentle expand (~0.45 s)
        withAnimation(.easeInOut(duration: 0.45)) {
            logoScale = 1.15
        }
        await sleep(450 + 250)

        // 3 · Fade to dark, reveal login (~0.55 s)
        withAnimation(.easeInOut(duration: 0.55)) {
            fadeAlpha = 1
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

        // 7 · Logo + quote emerge together (~0.50 s) ─────────────────────────
        logoY = -160
        quoteText = Quotes.amazing.randomElement() ?? ""
        withAnimation(.easeIn(duration: 0.50)) { quoteOpacity = 1 }
        await ease(0.50) { logoOpacity = 1; logoScale = 0.85; logoY = -155 }
        await sleep(100)

        // 8 · Logo expands to centre (~0.45 s) ────────────────────────────────
        await ease(0.45) { logoScale = 1.25; logoY = -150; glowAlpha = 0 }
        await sleep(300)

        // 9 · Fade to dark, reveal login (~0.55 s) ────────────────────────────
        await ease(0.55) { fadeAlpha = 1 }
        await sleep(120)

        onComplete()
    }
}

#Preview {
    SheRiseIntroView { }
}
