# Wombitious 🌟

**Empowering ambitious women to achieve their goals through AI-powered breakdown, gamification, and community support.**

## About

Wombitious is an iOS app designed for ambitious women who have big goals but don't know where to start. The app:
- 🤖 Uses Gemini AI to break down big goals into actionable micro-targets
- 🎮 Gamifies progress with points, badges, and confidence scoring
- 💪 Builds confidence through tracking and celebrating small wins
- 💖 Provides inspiration through success stories from other women

## Features

### Core Features
- **AI-Powered Goal Breakdown**: Enter your big goal, and Gemini AI generates 5-7 specific, actionable steps
- **Multiple Goal Types**: Career, Education, Financial, and Personal goals supported
- **Progress Tracking**: Visual progress indicators and completion tracking
- **Gamification**:
  - Earn points for completing micro-targets
  - Build streaks by staying consistent
  - Unlock badges for achievements
  - Watch your confidence score grow
- **Inspiring Stories**: Read success stories from other ambitious women
- **Beautiful UI**: Clean, modern interface optimized for iPhone and iPad

## Tech Stack

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent data storage
- **Gemini AI API**: Intelligent goal breakdown
- **iOS 17+**: Latest iOS features

## Setup Instructions

### 1. Open the Project in Xcode
1. Double-click `Wombitious.xcodeproj` to open in Xcode
2. Make sure you have Xcode 15+ installed

### 2. Get Your Gemini API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your API key

### 3. Add Your API Key to the App
1. Open `Services/GeminiService.swift`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:
   ```swift
   private let apiKey = "YOUR_ACTUAL_API_KEY_HERE"
   ```

### 4. Configure Your Team
1. Select the Wombitious project in Xcode
2. Go to "Signing & Capabilities"
3. Select your team under "Team"

### 5. Run the App
1. Select a simulator or your device
2. Press Cmd+R or click the Play button
3. The app will build and run!

## Project Structure

```
Wombitious/
├── Models/
│   ├── Goal.swift              # Goal data model
│   ├── MicroTarget.swift       # Micro-target data model
│   ├── Story.swift             # Story data model
│   └── UserProgress.swift      # User progress & gamification
├── Views/
│   ├── DashboardView.swift     # Main dashboard
│   ├── OnboardingView.swift    # Welcome screens
│   ├── GoalCreationView.swift  # Goal creation form
│   ├── StoriesView.swift       # Success stories gallery
│   └── ProfileView.swift       # User profile & badges
├── Services/
│   └── GeminiService.swift     # Gemini API integration
├── ContentView.swift           # Main tab navigation
└── WombitiousApp.swift         # App entry point
```

## How to Use

### Creating Your First Goal
1. Open the app - you'll see the onboarding flow
2. Tap "Get Started" to skip to the main screen
3. Tap the "+" button or "Create Your Goal"
4. Select your goal type (Career, Education, Financial, Personal)
5. Enter a title and detailed description
6. Tap "Create Goal & Generate Steps"
7. The AI will generate actionable micro-targets!

### Tracking Progress
- Check off micro-targets as you complete them
- Earn 10 points per completed target
- Build streaks by completing targets on consecutive days
- Watch your confidence score grow

### Earning Badges
- 🌟 **First Step**: Complete your first micro-target
- ⚡️ **Week Warrior**: Maintain a 7-day streak
- 🏆 **Goal Crusher**: Complete a full goal
- 🔥 **Streak Master**: Achieve a 30-day streak
- 💪 **Confident**: Reach 80+ confidence score

## Development Timeline (10 Days)

- ✅ **Days 1-2**: Project setup, data models, navigation
- **Days 3-4**: Gemini API integration, goal creation
- **Days 5-6**: Progress tracking, gamification
- **Days 7-8**: Stories, iPad optimization
- **Days 9-10**: Polish, testing, submission prep

## Testing

The app includes:
- Swift Testing for unit tests
- XCTest UI tests for integration testing

Run tests with: `Cmd+U`

## Future Enhancements

- User accounts and cloud sync
- Social features (share stories, comment)
- Notifications for streak reminders
- Multiple simultaneous goals
- Goal templates by category
- Voice notes for reflections

## Submission

Created for the **Apple Swift Student Challenge 2025**

## License

This project is created for educational purposes as part of the Apple Swift Student Challenge.

---

**Made with 💖 by Kashaf Batool**
