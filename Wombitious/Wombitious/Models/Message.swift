//
//  Message.swift
//  Wombitious
//

import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var senderName: String
    var content: String
    var isRead: Bool
    var createdDate: Date

    init(senderName: String, content: String) {
        self.id = UUID()
        self.senderName = senderName
        self.content = content
        self.isRead = false
        self.createdDate = Date()
    }
}
