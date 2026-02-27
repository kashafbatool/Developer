//
//  Story.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation
import SwiftData

@Model
final class Story {
    var id: UUID
    var authorName: String
    var goalTitle: String
    var goalType: GoalType
    var storyText: String
    var advice: String
    var timeToComplete: String // e.g., "6 months", "1 year"
    var createdDate: Date
    var likes: Int

    init(
        authorName: String,
        goalTitle: String,
        goalType: GoalType,
        storyText: String,
        advice: String,
        timeToComplete: String
    ) {
        self.id = UUID()
        self.authorName = authorName
        self.goalTitle = goalTitle
        self.goalType = goalType
        self.storyText = storyText
        self.advice = advice
        self.timeToComplete = timeToComplete
        self.createdDate = Date()
        self.likes = 0
    }
}
