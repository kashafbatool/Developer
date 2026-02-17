//
//  Goal.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var title: String
    var goalDescription: String
    var type: GoalType
    var createdDate: Date
    var targetDate: Date?
    var isCompleted: Bool
    var completedDate: Date?

    @Relationship(deleteRule: .cascade) var microTargets: [MicroTarget]

    init(
        title: String,
        description: String,
        type: GoalType,
        targetDate: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.goalDescription = description
        self.type = type
        self.createdDate = Date()
        self.targetDate = targetDate
        self.isCompleted = false
        self.microTargets = []
    }

    var progressPercentage: Double {
        guard !microTargets.isEmpty else { return 0 }
        let completed = microTargets.filter { $0.isCompleted }.count
        return Double(completed) / Double(microTargets.count) * 100
    }
}

enum GoalType: String, Codable, CaseIterable {
    case career = "Career"
    case education = "Education"
    case financial = "Financial"
    case personal = "Personal"

    var icon: String {
        switch self {
        case .career: return "briefcase.fill"
        case .education: return "graduationcap.fill"
        case .financial: return "dollarsign.circle.fill"
        case .personal: return "heart.fill"
        }
    }

    var color: String {
        switch self {
        case .career: return "blue"
        case .education: return "purple"
        case .financial: return "green"
        case .personal: return "pink"
        }
    }
}
