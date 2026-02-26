//
//  VisionItem.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation
import SwiftData

enum VisionItemType: String, Codable {
    case quote
    case image
}

@Model
final class VisionItem {
    var id: UUID
    var type: VisionItemType
    var content: String      // text for quotes; empty for images
    var imageData: Data?     // compressed image data
    var colorIndex: Int      // background colour preset
    var rotation: Double     // slight tilt for scrapbook feel
    var createdDate: Date

    init(type: VisionItemType, content: String = "", imageData: Data? = nil, colorIndex: Int = 0) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.imageData = imageData
        self.colorIndex = colorIndex
        // Random slight rotation for scrapbook feel
        self.rotation = Double.random(in: -5...5)
        self.createdDate = Date()
    }
}
