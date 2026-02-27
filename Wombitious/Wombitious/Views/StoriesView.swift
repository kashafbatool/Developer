//
//  StoriesView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData

struct StoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stories: [Story]
    @State private var selectedType: GoalType?

    var filteredStories: [Story] {
        if let type = selectedType {
            return stories.filter { $0.goalType == type }
        }
        return stories
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(title: "All", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            ForEach(GoalType.allCases, id: \.self) { type in
                                FilterChip(title: type.rawValue, isSelected: selectedType == type) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 14)

                    if filteredStories.isEmpty {
                        EmptyStoriesState()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredStories) { story in
                                    StoryCard(story: story)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Stories")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .onAppear {
                if stories.isEmpty { seedStories() }
            }
        }
    }

    func seedStories() {
        let sampleStories = [
            Story(
                authorName: "Sarah K.",
                goalTitle: "Landed My Dream Tech Internship",
                goalType: .career,
                storyText: "I was intimidated by applying to tech companies, but breaking it down into small steps made it manageable. I started with updating my resume, then practiced coding problems for 30 minutes daily, reached out to 5 people for informational interviews, and applied consistently. After 3 months, I got offers from 2 companies!",
                advice: "Don't wait until you feel 'ready.' Start with one small step today. Consistency beats perfection every time.",
                timeToComplete: "3 months"
            ),
            Story(
                authorName: "Maya P.",
                goalTitle: "Learned to Code and Built My First App",
                goalType: .education,
                storyText: "As someone with zero coding experience, I thought building an app was impossible. I started with free online courses, spent 1 hour daily learning Swift, joined online communities for support, and celebrated every small win. Six months later, my app is on the App Store!",
                advice: "Learning to code is a marathon, not a sprint. Be patient with yourself and celebrate every milestone.",
                timeToComplete: "6 months"
            ),
            Story(
                authorName: "Aisha M.",
                goalTitle: "Saved $5,000 for My First Solo Trip",
                goalType: .financial,
                storyText: "I've always wanted to travel alone but never thought I could afford it. I created a budget, cut unnecessary subscriptions, started a side hustle tutoring online, and automatically transferred $200 to savings monthly. It felt impossible at first, but seeing that number grow motivated me to keep going.",
                advice: "Automate your savings and find a side income stream. Small amounts add up faster than you think!",
                timeToComplete: "10 months"
            ),
            Story(
                authorName: "Priya S.",
                goalTitle: "Completed My First Marathon",
                goalType: .personal,
                storyText: "I couldn't run a mile when I started. But I committed to a training plan: started with walk/run intervals, gradually increased distance each week, joined a running group for accountability, and signed up for a race 6 months out. Crossing that finish line was one of the proudest moments of my life!",
                advice: "Your body is capable of so much more than you think. Trust the process and don't skip rest days!",
                timeToComplete: "6 months"
            ),
            Story(
                authorName: "Emma L.",
                goalTitle: "Started My Own Business",
                goalType: .career,
                storyText: "I was working a 9-5 I didn't love but was scared to leave. I started my business as a side project: validated my idea by talking to potential customers, built a simple MVP in 3 months, got my first paying customer, and scaled from there. A year later, I quit my job and went full-time!",
                advice: "You don't need everything figured out to start. Test your idea, get feedback early, and iterate.",
                timeToComplete: "1 year"
            )
        ]
        for story in sampleStories { modelContext.insert(story) }
        try? modelContext.save()
    }
}

struct StoryCard: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.goalTitle)
                        .font(.headline)
                        .foregroundStyle(Color.appPlum)
                    Text("by \(story.authorName)")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: story.goalType.icon)
                        .font(.caption2)
                    Text(story.goalType.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(colorForType(story.goalType).opacity(0.12))
                .foregroundStyle(colorForType(story.goalType))
                .clipShape(Capsule())
            }

            Text(story.storyText)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineSpacing(3)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.appGold)
                    .font(.subheadline)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Key Takeaway")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(story.advice)
                        .font(.subheadline)
                        .foregroundStyle(Color.appPlum)
                        .italic()
                }
            }
            .padding(12)
            .background(Color.appGold.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack {
                Label(story.timeToComplete, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Label("\(story.likes)", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(Color.appCoral)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.06), radius: 10, y: 4)
    }

    func colorForType(_ type: GoalType) -> Color {
        switch type {
        case .career: return .blue
        case .education: return .purple
        case .financial: return .green
        case .personal: return Color.appCoral
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(isSelected ? Color.appPlum : Color.white)
                .foregroundStyle(isSelected ? .white : Color.appPlum)
                .clipShape(Capsule())
                .shadow(color: isSelected ? Color.appPlum.opacity(0.25) : .black.opacity(0.04), radius: 6, y: 2)
        }
    }
}

struct EmptyStoriesState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.appGold.opacity(0.5))
            Text("No stories yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appPlum)
            Text("Check back soon for inspiring stories!")
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    StoriesView()
        .modelContainer(for: Story.self)
}
