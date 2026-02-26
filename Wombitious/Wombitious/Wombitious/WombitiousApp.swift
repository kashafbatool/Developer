//
//  WombitiousApp.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData

@main
struct WombitiousApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Goal.self,
            MicroTarget.self,
            Story.self,
            UserProgress.self,
            JournalEntry.self,
            VisionItem.self
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
        }
        .modelContainer(sharedModelContainer)
    }
}
