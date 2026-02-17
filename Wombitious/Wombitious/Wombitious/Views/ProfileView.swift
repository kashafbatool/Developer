//
//  ProfileView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    let userProgress: UserProgress

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats Overview
                    VStack(spacing: 16) {
                        Text("Your Progress")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 20) {
                            StatCard(
                                title: "Points",
                                value: "\(userProgress.totalPoints)",
                                icon: "star.fill",
                                color: .yellow
                            )

                            StatCard(
                                title: "Streak",
                                value: "\(userProgress.currentStreak)",
                                icon: "flame.fill",
                                color: .orange
                            )

                            StatCard(
                                title: "Best Streak",
                                value: "\(userProgress.longestStreak)",
                                icon: "trophy.fill",
                                color: .purple
                            )
                        }
                    }

                    // Badges Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Badges")
                            .font(.title2)
                            .fontWeight(.bold)

                        if userProgress.badges.isEmpty {
                            EmptyBadgesView()
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(Badge.allCases, id: \.self) { badge in
                                    BadgeCard(
                                        badge: badge,
                                        isEarned: userProgress.badges.contains(badge.rawValue)
                                    )
                                }
                            }
                        }
                    }

                    // Motivational Quote
                    MotivationalQuoteCard()
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

struct BadgeCard: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(badge.icon)
                .font(.system(size: 40))
                .opacity(isEarned ? 1.0 : 0.3)

            Text(badge.title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(badge.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isEarned ? Color(.systemBackground) : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEarned ? Color.pink : Color.clear, lineWidth: 2)
        )
        .opacity(isEarned ? 1.0 : 0.6)
    }
}

struct EmptyBadgesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "medal.fill")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("Start earning badges!")
                .font(.headline)

            Text("Complete micro-targets and maintain streaks to unlock achievements.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MotivationalQuoteCard: View {
    let quotes = [
        "The secret of getting ahead is getting started.",
        "Don't watch the clock; do what it does. Keep going.",
        "You are capable of amazing things.",
        "Small steps every day lead to big changes.",
        "Believe you can and you're halfway there.",
        "The only impossible journey is the one you never begin.",
        "Your ambition is your superpower."
    ]

    var randomQuote: String {
        quotes.randomElement() ?? quotes[0]
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title)
                .foregroundStyle(.pink)

            Text(randomQuote)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)

            Image(systemName: "quote.closing")
                .font(.title)
                .foregroundStyle(.pink)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.pink.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ProfileView(userProgress: UserProgress())
}
