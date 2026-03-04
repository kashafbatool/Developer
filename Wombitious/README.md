# SheRise 🌟

**An AI-powered goal tracking app for ambitious women — break big dreams into actionable steps, stay consistent, and celebrate every win.**

## About

Wombitious is an iOS app designed for women who have big goals but don't know where to start. It uses Gemini AI to turn vague ambitions into a concrete, personalised action plan — then keeps you motivated with gamification, a daily journal, and a vision board.

## Features

### AI-Powered Goal Breakdown
- Describe your dream in plain language and Gemini AI extracts a focused goal title
- Generates 7 specific, timeline-aware action steps (no jargon — written like a smart friend giving real advice)
- Steps are grouped into **Quick Wins**, **Building Phase**, and **Big Moves** based on your chosen timeline (1 month → 1 year)

### Today's Focus
- One highlighted task at the top of your dashboard each session
- Ticking it off shows a "Done for today — come back tomorrow" state instead of auto-advancing

### Gamification
- **Confidence Score** — grows as you complete steps (0–100)
- **Rank system** — Dreamer → Builder → Achiever → Trailblazer → Wombitious
- **Streak tracking** with longest streak record
- **2x Momentum Multiplier** — double points on any 3+ day streak
- **Energy multiplier** — daily check-in (1–5 scale) gives bonus points at high energy
- **Streak Freeze tokens** — auto-earned every 7-day streak, auto-used if you miss a day
- **Badges** — First Step, Week Warrior, Goal Crusher, Streak Master, Confident, Comeback Queen
- **Goal Completion Ceremony** — full-screen confetti celebration when a goal is finished

### Activity Heatmap
- GitHub-style 10-week activity grid on your Profile
- Cell colour intensity reflects how many tasks were completed that day (up to 4 levels)
- Tap any active day to see the exact task count

### Daily Journal
- Scrapbook paper aesthetic: cream background, white card with drop shadow
- Washi tape decoration in 5 colours applied to each entry
- Mood selector (😔 → 🔥) and tape style picker on new entries
- Star your favourite entries, filter by starred, delete via long-press

### Vision Board
- Dark, moody board with a 2-column masonry grid
- Add **photos** from your photo library or **quote cards** with 5 background colour options
- Each item gets a slight random rotation for a scrapbook feel

### Profile
- Avatar (photo or emoji from 12 presets) + display name
- Editable via "Edit" button in the profile screen
- Badges gallery, streak freeze display, motivational quote card

### Stories
- Browse inspiring success stories from other ambitious women

## Tech Stack

- **SwiftUI** — declarative UI
- **SwiftData** — on-device persistent storage (schema auto-migrates)
- **Gemini AI API** (`gemini-flash-latest`) — goal extraction + step generation
- **PhotosUI** — photo picker for profile + vision board
- **iOS 17+**

## Project Structure

```
Wombitious/
├── Models/
│   ├── Goal.swift              # Goal + timeline
│   ├── MicroTarget.swift       # Action step
│   ├── Story.swift             # Inspiration story
│   ├── UserProgress.swift      # Points, streaks, badges, rank, heatmap
│   ├── JournalEntry.swift      # Journal entry (mood, tape style)
│   └── VisionItem.swift        # Vision board item (quote or image)
├── Views/
│   ├── DashboardView.swift     # Home tab — focus card, goals, steps
│   ├── JournalView.swift       # Journal tab — paper/tape entries
│   ├── VisionBoardView.swift   # Vision tab — photo + quote board
│   ├── StoriesView.swift       # Stories tab
│   ├── ProfileView.swift       # Profile tab — rank, heatmap, badges
│   ├── ProfileEditView.swift   # Edit name + avatar
│   ├── GoalCreationView.swift  # Multi-step goal creation flow
│   ├── GoalCompletionView.swift# Celebration screen
│   ├── EnergyCheckInView.swift # Daily energy check-in
│   └── OnboardingView.swift    # Welcome screens
├── Services/
│   └── GeminiService.swift     # Gemini API calls
├── ContentView.swift           # Tab navigation
├── Theme.swift                 # Colours + design tokens
└── WombitiousApp.swift         # App entry point + SwiftData schema
```

## Setup

### Prerequisites
- Xcode 15+
- iOS 17+ simulator or device

### 1. Open the project
Double-click `Wombitious.xcodeproj`

### 2. Add your Gemini API key
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey) and create an API key
2. Open `Services/GeminiService.swift`
3. Replace the placeholder with your key:
   ```swift
   private let apiKey = "YOUR_API_KEY_HERE"
   ```

### 3. Set your signing team
In Xcode → Signing & Capabilities → select your Apple Developer team

### 4. Run
Press `Cmd+R`

## How to Use

### Creating a goal
1. Tap **+** on the Home tab
2. Describe your dream ("I want to run a marathon")
3. Confirm the extracted goal title and pick a timeline
4. The AI generates your personalised action plan

### Daily flow
- Complete your **Today's Focus** task
- Tick off other steps in the list to earn points
- Check back tomorrow — focus won't jump to the next task mid-session

### Journal
- Tap **Journal** tab → pencil icon to write an entry
- Choose your mood and washi tape colour
- Long-press an entry to star or delete it

### Vision Board
- Tap **Vision** tab → **+** to add a quote or photo
- Long-press an item to remove it

### Profile
- Tap **Profile** → **Edit** to set your name and avatar

## Badges

| Badge | How to earn |
|---|---|
| 🌟 First Step | Complete your first action step |
| ⚡️ Week Warrior | Maintain a 7-day streak |
| 🏆 Goal Crusher | Complete a full goal |
| 🔥 Streak Master | Achieve a 30-day streak |
| 💪 Confident | Reach 80+ confidence score |
| 👑 Comeback Queen | Return after a 3+ day break |

---

**Made with 💖 by Kashaf Batool**
