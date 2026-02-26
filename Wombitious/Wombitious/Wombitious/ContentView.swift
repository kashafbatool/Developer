//
//  ContentView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal]
    @Query private var userProgress: [UserProgress]
    @State private var showOnboarding = false

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
        .modelContainer(for: [Goal.self, UserProgress.self, Story.self, JournalEntry.self, VisionItem.self])
}
