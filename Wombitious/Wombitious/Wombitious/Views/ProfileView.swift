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
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        ProfileHeaderCard()
                        StatsRow(userProgress: userProgress)
                        BadgesSection(userProgress: userProgress)
                        MotivationalQuoteCard()
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

struct ProfileHeaderCard: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appGold.opacity(0.2))
                    .frame(width: 60, height: 60)
                Text("✨")
                    .font(.title)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Your Progress")
                    .font(.headline)
                    .foregroundStyle(Color.appPlum)
                Text("Keep showing up every day")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.06), radius: 10, y: 4)
    }
}

struct StatsRow: View {
    let userProgress: UserProgress

    var body: some View {
        HStack(spacing: 12) {
            StatCard(title: "Points", value: "\(userProgress.totalPoints)", icon: "star.fill", color: Color.appGold)
            StatCard(title: "Streak", value: "\(userProgress.currentStreak)d", icon: "flame.fill", color: Color.appCoral)
            StatCard(title: "Best", value: "\(userProgress.longestStreak)d", icon: "trophy.fill", color: Color.appPlum)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.appPlum)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}

struct BadgesSection: View {
    let userProgress: UserProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Badges")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.appPlum)

            if userProgress.badges.isEmpty {
                EmptyBadgesView()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(Badge.allCases, id: \.self) { badge in
                        BadgeCard(
                            badge: badge,
                            isEarned: userProgress.badges.contains(badge.rawValue)
                        )
                    }
                }
            }
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 10) {
            Text(badge.icon)
                .font(.system(size: 36))
                .opacity(isEarned ? 1.0 : 0.25)

            Text(badge.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isEarned ? Color.appPlum : Color.appTextSecondary)

            Text(badge.description)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(isEarned ? Color.white : Color(red: 0.94, green: 0.94, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isEarned ? Color.appGold : Color.clear, lineWidth: 2)
        )
        .shadow(color: isEarned ? Color.appGold.opacity(0.2) : .clear, radius: 8, y: 3)
    }
}

struct EmptyBadgesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "medal.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.appGold.opacity(0.4))

            Text("Start earning badges!")
                .font(.headline)
                .foregroundStyle(Color.appPlum)

            Text("Complete micro-targets and maintain streaks to unlock achievements.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        VStack(spacing: 14) {
            Text("✦")
                .font(.title2)
                .foregroundStyle(Color.appGold)

            Text(randomQuote)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("✦")
                .font(.title2)
                .foregroundStyle(Color.appGold)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.appPlum)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.25), radius: 12, y: 6)
    }
}

#Preview {
    ProfileView(userProgress: UserProgress())
}
