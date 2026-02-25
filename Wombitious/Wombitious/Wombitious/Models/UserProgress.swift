//
//  UserProgress.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation
import SwiftData

@Model
final class UserProgress {
    var id: UUID
    var totalPoints: Int
    var confidenceScore: Int // 0-100
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var badges: [String] // Badge identifiers
    var lastCheckInDate: Date?
    var todayEnergyLevel: Int // 0 = not checked in, 1-5

    init() {
        self.id = UUID()
        self.totalPoints = 0
        self.confidenceScore = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.badges = []
        self.lastCheckInDate = nil
        self.todayEnergyLevel = 0
    }

    var needsDailyCheckIn: Bool {
        guard let lastDate = lastCheckInDate else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }

    func recordCheckIn(energyLevel: Int) {
        todayEnergyLevel = energyLevel
        lastCheckInDate = Date()
    }

    func addPoints(_ points: Int) {
        totalPoints += points
        updateConfidenceScore()
    }

    func updateStreak() {
        let calendar = Calendar.current
        if let lastDate = lastActivityDate {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0

            if daysBetween == 1 {
                // Consecutive day
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
            // If daysBetween == 0, same day, don't update streak
        } else {
            // First activity
            currentStreak = 1
            longestStreak = 1
        }

        lastActivityDate = Date()
    }

    private func updateConfidenceScore() {
        // Confidence score increases with points
        // Cap at 100
        confidenceScore = min(100, totalPoints / 10)
    }

    func addBadge(_ badgeId: String) {
        if !badges.contains(badgeId) {
            badges.append(badgeId)
        }
    }
}

// Badge definitions
enum Badge: String, CaseIterable {
    case firstStep = "first_step"
    case weekWarrior = "week_warrior"
    case goalCrusher = "goal_crusher"
    case streakMaster = "streak_master"
    case confident = "confident"

    var title: String {
        switch self {
        case .firstStep: return "First Step"
        case .weekWarrior: return "Week Warrior"
        case .goalCrusher: return "Goal Crusher"
        case .streakMaster: return "Streak Master"
        case .confident: return "Confident"
        }
    }

    var description: String {
        switch self {
        case .firstStep: return "Completed your first micro-target"
        case .weekWarrior: return "Maintained a 7-day streak"
        case .goalCrusher: return "Completed a full goal"
        case .streakMaster: return "Achieved a 30-day streak"
        case .confident: return "Reached 80+ confidence score"
        }
    }

    var icon: String {
        switch self {
        case .firstStep: return "🌟"
        case .weekWarrior: return "⚡️"
        case .goalCrusher: return "🏆"
        case .streakMaster: return "🔥"
        case .confident: return "💪"
        }
    }
}
