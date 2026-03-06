//
//  Message.swift
//  Wombitious
//

import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var content: String
    var isRead: Bool
    var createdDate: Date
    var unlockDate: Date
    var deliveryLabel: String  // "1 Week", "1 Month", "1 Year"

    init(content: String, unlockDate: Date, deliveryLabel: String) {
        self.id = UUID()
        self.content = content
        self.isRead = false
        self.createdDate = Date()
        self.unlockDate = unlockDate
        self.deliveryLabel = deliveryLabel
    }

    var isUnlocked: Bool { unlockDate <= Date() }
}
