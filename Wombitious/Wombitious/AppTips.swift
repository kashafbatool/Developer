//
//  AppTips.swift
//  SheRise
//
//  Created by Kashaf Batool
//

import TipKit

/// Shown on the dashboard when the user has a goal but hasn't tapped Today's Focus yet.
struct FocusTip: Tip {
    var title: Text { Text("Your daily focus") }
    var message: Text? { Text("This is your one task for today. Complete it to keep your streak going — don't worry about the rest.") }
    var image: Image? { Image(systemName: "star.circle.fill") }
}

/// Shown on the + button when no goals exist yet.
struct CreateGoalTip: Tip {
    var title: Text { Text("Set your first goal") }
    var message: Text? { Text("Tell SheRise your dream and our AI will turn it into clear, manageable steps.") }
    var image: Image? { Image(systemName: "sparkles") }
}

/// Shown on the Journal tab.
struct JournalTip: Tip {
    var title: Text { Text("Your private journal") }
    var message: Text? { Text("Write about your progress, how you're feeling, or anything on your mind. Pick a washi tape to make it yours.") }
    var image: Image? { Image(systemName: "book.pages") }
}
