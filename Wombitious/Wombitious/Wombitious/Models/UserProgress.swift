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
    var confidenceScore: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var badges: [String]
    var lastCheckInDate: Date?
    var todayEnergyLevel: Int
    var streakFreezeTokens: Int
    var activityDates: [String]  // "yyyy-MM-dd:count" strings for heatmap
    var username: String
    var avatarEmoji: String
    var profileImageData: Data?

    init() {
        self.id = UUID()
        self.totalPoints = 0
        self.confidenceScore = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.badges = []
        self.lastCheckInDate = nil
        self.todayEnergyLevel = 0
        self.streakFreezeTokens = 0
        self.activityDates = []
        self.username = ""
        self.avatarEmoji = "✨"
    }

    // MARK: - Rank
    var rank: String {
        switch confidenceScore {
        case 0..<20: return "Dreamer"
        case 20..<40: return "Builder"
        case 40..<60: return "Achiever"
        case 60..<80: return "Trailblazer"
        default: return "Wombitious"
        }
    }

    var rankIcon: String {
        switch confidenceScore {
        case 0..<20: return "sparkle"
        case 20..<40: return "hammer.fill"
        case 40..<60: return "star.fill"
        case 60..<80: return "flame.fill"
        default: return "crown.fill"
        }
    }

    var nextRankName: String {
        switch confidenceScore {
        case 0..<20: return "Builder"
        case 20..<40: return "Achiever"
        case 40..<60: return "Trailblazer"
        case 60..<80: return "Wombitious"
        default: return "Max"
        }
    }

    var nextRankThreshold: Int {
        switch confidenceScore {
        case 0..<20: return 20
        case 20..<40: return 40
        case 40..<60: return 60
        case 60..<80: return 80
        default: return 100
        }
    }

    var currentRankMin: Int {
        switch confidenceScore {
        case 0..<20: return 0
        case 20..<40: return 20
        case 40..<60: return 40
        case 60..<80: return 60
        default: return 80
        }
    }

    var rankProgress: Double {
        guard confidenceScore < 80 else { return 1.0 }
        let range = Double(nextRankThreshold - currentRankMin)
        let current = Double(confidenceScore - currentRankMin)
        return range > 0 ? current / range : 0
    }

    // MARK: - Multipliers
    var momentumMultiplier: Double {
        currentStreak >= 3 ? 2.0 : 1.0
    }

    var energyMultiplier: Double {
        switch todayEnergyLevel {
        case 5: return 1.2
        case 4: return 1.1
        default: return 1.0
        }
    }

    // MARK: - Check-in
    var needsDailyCheckIn: Bool {
        guard let lastDate = lastCheckInDate else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }

    func recordCheckIn(energyLevel: Int) {
        todayEnergyLevel = energyLevel
        lastCheckInDate = Date()
    }

    // MARK: - Points & streak
    func addPoints(_ points: Int) {
        let multiplied = Int(Double(points) * momentumMultiplier * energyMultiplier)
        totalPoints += multiplied
        updateConfidenceScore()
    }

    func updateStreak() {
        let calendar = Calendar.current
        recordActivityDate()

        if let lastDate = lastActivityDate {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0

            if daysBetween == 1 {
                currentStreak += 1
                if currentStreak > longestStreak { longestStreak = currentStreak }
                if currentStreak % 7 == 0 { streakFreezeTokens += 1 }  // free token every week
            } else if daysBetween == 2 && streakFreezeTokens > 0 {
                streakFreezeTokens -= 1  // auto-use freeze
                currentStreak += 1
                if currentStreak > longestStreak { longestStreak = currentStreak }
            } else if daysBetween > 1 {
                if daysBetween >= 3 { addBadge(Badge.comingBack.rawValue) }
                currentStreak = 1
            }
        } else {
            currentStreak = 1
            longestStreak = 1
        }

        lastActivityDate = Date()
    }

    private func recordActivityDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        if let idx = activityDates.firstIndex(where: { $0.hasPrefix(today + ":") || $0 == today }) {
            let parts = activityDates[idx].split(separator: ":").map(String.init)
            let currentCount = parts.count == 2 ? (Int(parts[1]) ?? 1) : 1
            activityDates[idx] = "\(today):\(currentCount + 1)"
        } else {
            activityDates.append("\(today):1")
        }
    }

    func completionCount(for date: Date) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        guard let entry = activityDates.first(where: { $0.hasPrefix(key + ":") || $0 == key }) else { return 0 }
        let parts = entry.split(separator: ":").map(String.init)
        return parts.count == 2 ? (Int(parts[1]) ?? 1) : 1
    }

    func isActiveDay(_ date: Date) -> Bool {
        completionCount(for: date) > 0
    }

    private func updateConfidenceScore() {
        confidenceScore = min(100, totalPoints / 10)
    }

    func addBadge(_ badgeId: String) {
        if !badges.contains(badgeId) {
            badges.append(badgeId)
        }
    }
}

// MARK: - Badge definitions
enum Badge: String, CaseIterable {
    case firstStep = "first_step"
    case weekWarrior = "week_warrior"
    case goalCrusher = "goal_crusher"
    case streakMaster = "streak_master"
    case confident = "confident"
    case comingBack = "coming_back"

    var title: String {
        switch self {
        case .firstStep: return "First Step"
        case .weekWarrior: return "Week Warrior"
        case .goalCrusher: return "Goal Crusher"
        case .streakMaster: return "Streak Master"
        case .confident: return "Confident"
        case .comingBack: return "Comeback Queen"
        }
    }

    var description: String {
        switch self {
        case .firstStep: return "Completed your first micro-target"
        case .weekWarrior: return "Maintained a 7-day streak"
        case .goalCrusher: return "Completed a full goal"
        case .streakMaster: return "Achieved a 30-day streak"
        case .confident: return "Reached 80+ confidence score"
        case .comingBack: return "Took a break and came back stronger"
        }
    }

    var icon: String {
        switch self {
        case .firstStep: return "🌟"
        case .weekWarrior: return "⚡️"
        case .goalCrusher: return "🏆"
        case .streakMaster: return "🔥"
        case .confident: return "💪"
        case .comingBack: return "👑"
        }
    }
}
