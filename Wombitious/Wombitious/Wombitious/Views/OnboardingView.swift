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
            title: "Welcome to\nSheRise",
            description: "Your journey to achieving ambitious goals starts here. We're here to support you every step of the way.",
            color: Color.appPlum
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "AI Breaks It\nDown For You",
            description: "Share your big goal and our AI generates 5-7 specific, actionable steps tailored just for you.",
            color: Color(red: 0.31, green: 0.14, blue: 0.50)
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Watch Your\nConfidence Grow",
            description: "Track progress, earn badges, and see your confidence score climb with every small win.",
            color: Color.appPlum
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Get Inspired\nEvery Day",
            description: "Read real stories from ambitious women who turned their dreams into reality.",
            color: Color(red: 0.31, green: 0.14, blue: 0.50)
        )
    ]

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            showOnboarding = false
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .padding()
                    }
                }

                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif

                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index == currentPage ? Color.appPlum : Color.appPlum.opacity(0.2))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            showOnboarding = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(currentPage < pages.count - 1 ? "Continue" : "Let's Begin")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.appPlum)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
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
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.06))
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: page.icon)
                    .font(.system(size: 52))
                    .foregroundStyle(page.color)
            }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.appPlum)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }

            Spacer()
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
