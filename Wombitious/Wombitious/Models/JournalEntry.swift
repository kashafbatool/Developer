//
//  JournalEntry.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var content: String
    var mood: Int        // 1–5
    var tapeStyle: Int   // 0–4 (color/style of tape decoration)
    var isStarred: Bool

    init(content: String, mood: Int = 3, tapeStyle: Int = 0) {
        self.id = UUID()
        self.date = Date()
        self.content = content
        self.mood = mood
        self.tapeStyle = tapeStyle
        self.isStarred = false
    }

    var moodEmoji: String {
        switch mood {
        case 1: return "😔"
        case 2: return "😐"
        case 3: return "🙂"
        case 4: return "😊"
        case 5: return "🔥"
        default: return "🙂"
        }
    }
}
