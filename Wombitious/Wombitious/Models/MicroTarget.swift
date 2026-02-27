//
//  MicroTarget.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation
import SwiftData

@Model
final class MicroTarget {
    var id: UUID
    var title: String
    var targetDescription: String
    var order: Int
    var isCompleted: Bool
    var completedDate: Date?
    var estimatedDays: Int?

    @Relationship(inverse: \Goal.microTargets) var goal: Goal?

    init(
        title: String,
        description: String,
        order: Int,
        estimatedDays: Int? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.targetDescription = description
        self.order = order
        self.isCompleted = false
        self.estimatedDays = estimatedDays
    }

    func toggleCompletion() {
        isCompleted.toggle()
        completedDate = isCompleted ? Date() : nil
    }
}
