//
//  WombitiousApp.swift
//  SheRise
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData
import TipKit

@main
struct SheRiseApp: App {
    @StateObject private var authManager = AuthManager()

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 0.996, green: 0.996, blue: 0.890, alpha: 1)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Goal.self,
            MicroTarget.self,
            Story.self,
            UserProgress.self,
            JournalEntry.self,
            VisionItem.self,
            Message.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema changed — wipe the store and start fresh
            do {
                try FileManager.default.removeItem(at: modelConfiguration.url)
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    // Configure TipKit — show tips once per user in production
                    try? Tips.configure([
                        .displayFrequency(.immediate)
                    ])
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
