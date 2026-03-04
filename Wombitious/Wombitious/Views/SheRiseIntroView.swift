//
//  SheRiseIntroView.swift
//  sheRise
//

import SwiftUI

struct SheRiseIntroView: View {
    var onComplete: () -> Void

    @State private var logoOpacity: Double  = 0
    @State private var logoScale:   CGFloat = 0.75
    @State private var fadeAlpha:   Double  = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            Image("SheRiseLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 260)
                .scaleEffect(logoScale)
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
        await sleep(550 + 150)

        onComplete()
    }
}

#Preview {
    SheRiseIntroView { }
}
