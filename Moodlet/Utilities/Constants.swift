//
//  Constants.swift
//  Moodlet
//

import Foundation

enum Constants {
    enum Points {
        static let moodLog = 1
        static let contextTags = 1
        static let reflection = 2
        static let weeklyReview = 3
        static let maxDailyPointEntries = 3
    }

    enum Streaks {
        static let gracePeriodDays = 2
        static let milestone3Day = 3
        static let milestone7Day = 7
        static let milestone14Day = 14
        static let milestone30Day = 30
        static let milestone100Day = 100

        static let bonus3Day = 2
        static let bonus7Day = 5
        static let bonus14Day = 10
        static let bonus30Day = 15
        static let bonus100Day = 25
    }

    enum Animation {
        static let frameRate: TimeInterval = 1.0 / 12.0
        static let idleFrameCount = 24
    }

    enum Shop {
        static let cheapItemRange = 5...15
        static let midItemRange = 20...40
        static let premiumItemRange = 50...100
    }

    enum Onboarding {
        static let totalSteps = 8
    }
}

// MARK: - Notification Messages

enum NotificationMessages {
    static let morning = [
        "Good morning - how are you starting the day?",
        "Rise and shine - how are you feeling?",
        "Morning check-in time",
        "A new day begins - how's it going?",
        "Good morning! Ready for today's check-in?"
    ]

    static let afternoon = [
        "Afternoon check-in - how's it going?",
        "Midday moment - how are you?",
        "Taking a pause - how's your day?",
        "Checking in - how are things?",
        "Afternoon vibes - how are you feeling?"
    ]

    static let evening = [
        "Winding down - how was today?",
        "Evening reflection time",
        "End of day - how are you feeling?",
        "Time to reflect - how was your day?",
        "Evening check-in - how are you?"
    ]

    static let neutral = [
        "Your Moodlet is here when you're ready",
        "Ready for a check-in?",
        "How are you feeling right now?",
        "Take a moment to check in",
        "Your Moodlet is thinking of you"
    ]

    static func message(for hour: Int) -> String {
        switch hour {
        case 5..<12:
            return morning.randomElement() ?? neutral[0]
        case 12..<17:
            return afternoon.randomElement() ?? neutral[0]
        case 17..<22:
            return evening.randomElement() ?? neutral[0]
        default:
            return neutral.randomElement() ?? neutral[0]
        }
    }
}

// MARK: - Journal Prompts

enum JournalPrompts {
    static let prompts = [
        "What's on your mind?",
        "What influenced your mood today?",
        "One thing you noticed about yourself",
        "What are you grateful for right now?",
        "What's something that made you smile?",
        "What's been challenging lately?",
        "How are you taking care of yourself?",
        "What's one small win from today?",
        "What are you looking forward to?",
        "How did you show up for yourself today?"
    ]

    static func randomPrompts(count: Int = 3) -> [String] {
        Array(prompts.shuffled().prefix(count))
    }
}
