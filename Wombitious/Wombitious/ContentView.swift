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
            // Auth / main app always rendered beneath
            if !authManager.isAuthenticated {
                AuthView()
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
            // Show intro only when not logged in AND version is new
            showIntro = !authManager.isAuthenticated && introShownForVersion != appVersion
        }
    }

    private var mainTabView: some View {
        TabView {
            // Home/Dashboard
            DashboardView(goals: goals, userProgress: currentProgress)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // Daily Journal
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages")
                }

            // Vision Board
            VisionBoardView()
                .tabItem {
                    Label("Vision", systemImage: "sparkles.rectangle.stack.fill")
                }

            // Stories Gallery
            StoriesView()
                .tabItem {
                    Label("Stories", systemImage: "person.2.fill")
                }

            // Profile/Progress
            ProfileView(userProgress: currentProgress)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
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
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .modelContainer(for: [Goal.self, UserProgress.self, Story.self, JournalEntry.self, VisionItem.self])
}
