//
//  ContentView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var userProgress: [UserProgress]
    @State private var showOnboarding = false
    @State private var showCheckIn = false
    @State private var selectedTab = 0

    // Persist the app version for which the intro has already played.
    // Cleared automatically when the version string changes (install / update).
    @AppStorage("sheRise.introShownForVersion") private var introShownForVersion = ""
    @State private var showIntro = false

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(v).\(b)"
    }

    var currentProgress: UserProgress {
        if let progress = userProgress.first {
            return progress
        } else {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            return newProgress
        }
    }

    var body: some View {
        ZStack {
            // Auth / check-in / main app beneath
            if !authManager.isAuthenticated {
                AuthView()
                    .transition(.opacity)
            } else if showCheckIn {
                EnergyCheckInView(showCheckIn: $showCheckIn, userProgress: currentProgress)
                    .transition(.opacity)
            } else {
                mainTabView
            }

            // Intro sits on top and fades away — only on first run per version
            if showIntro && !authManager.isAuthenticated {
                SheRiseIntroView {
                    introShownForVersion = appVersion
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showIntro = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            showIntro = !authManager.isAuthenticated && introShownForVersion != appVersion
            // Only trigger check-in if user already has goals (already onboarded)
            if authManager.isAuthenticated && !goals.isEmpty && currentProgress.needsDailyCheckIn {
                showCheckIn = true
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuth in
            // Only trigger check-in if user already has goals (already onboarded)
            if isAuth && !goals.isEmpty && currentProgress.needsDailyCheckIn {
                showCheckIn = true
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView(goals: goals, userProgress: currentProgress)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            JournalView()
                .tabItem { Label("Journal", systemImage: "book.pages") }
                .tag(1)

            VisionBoardView()
                .tabItem { Label("Vision", systemImage: "sparkles.rectangle.stack.fill") }
                .tag(2)

            StoriesView()
                .tabItem { Label("Stories", systemImage: "person.2.fill") }
                .tag(3)

            ProfileView(userProgress: currentProgress)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .tint(Color.appPlum)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
        .onAppear {
            if goals.isEmpty {
                showOnboarding = true
            }
        }
        .onChange(of: showOnboarding) { _, showing in
            // After onboarding is dismissed, check if daily check-in is needed
            if !showing && currentProgress.needsDailyCheckIn {
                showCheckIn = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .modelContainer(for: [Goal.self, UserProgress.self, Story.self, JournalEntry.self, VisionItem.self])
}
