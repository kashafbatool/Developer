//
//  OnboardingView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0

    let pages = [
        OnboardingPage(
            icon: "star.fill",
            title: "Welcome to Wombitious",
            description: "Your journey to achieving ambitious goals starts here. We're here to support you every step of the way.",
            color: .pink
        ),
        OnboardingPage(
            icon: "lightbulb.fill",
            title: "AI-Powered Breakdown",
            description: "Share your big goal, and our AI will break it down into small, achievable micro-targets.",
            color: .purple
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Build Confidence",
            description: "Track your progress, earn badges, and watch your confidence score grow with each completed step.",
            color: .blue
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Get Inspired",
            description: "Read stories from other ambitious women who turned their dreams into reality.",
            color: .pink
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    showOnboarding = false
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundStyle(page.color)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
