//
//  ProfileView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData
import Charts

struct ProfileView: View {
    let userProgress: UserProgress
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        AvatarHeader(userProgress: userProgress, showEdit: $showEditProfile)
                        RankCard(userProgress: userProgress)
                        StatsRow(userProgress: userProgress)
                        WeeklyProgressChart(userProgress: userProgress)
                        ActivityHeatmap(userProgress: userProgress)
                        StreakFreezeSection(userProgress: userProgress)
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
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Text("Edit")
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appPlum)
                    }
                    .accessibilityLabel("Edit profile")
                }
            }
            .sheet(isPresented: $showEditProfile) {
                ProfileEditView(userProgress: userProgress)
            }
        }
    }
}

// MARK: - Avatar Header
struct AvatarHeader: View {
    let userProgress: UserProgress
    @Binding var showEdit: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appPlum.opacity(0.12))
                    .frame(width: 72, height: 72)
                if let data = userProgress.profileImageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                } else {
                    Text(userProgress.avatarEmoji)
                        .font(.system(size: 34))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(userProgress.username.isEmpty ? "SheRise" : userProgress.username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)
                Text(userProgress.rank)
                    .font(.subheadline)
                    .foregroundStyle(Color.appGold)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}

// MARK: - Rank Card
struct RankCard: View {
    let userProgress: UserProgress

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("YOUR RANK")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.65))
                        .tracking(1.5)
                    Text(userProgress.rank)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 60, height: 60)
                    Image(systemName: userProgress.rankIcon)
                        .font(.title2)
                        .foregroundStyle(Color.appGold)
                }
            }

            if userProgress.confidenceScore < 100 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next: \(userProgress.nextRankName)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text("\(userProgress.confidenceScore) / \(userProgress.nextRankThreshold) pts")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.2))
                                .frame(height: 7)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appGold)
                                .frame(width: geo.size.width * CGFloat(userProgress.rankProgress), height: 7)
                        }
                    }
                    .frame(height: 7)
                }
            } else {
                Text("Maximum rank achieved 👑")
                    .font(.subheadline)
                    .foregroundStyle(Color.appGold)
            }
        }
        .padding(20)
        .background(Color.appPlum)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.35), radius: 14, y: 6)
    }
}

// MARK: - Stats Row
struct StatsRow: View {
    let userProgress: UserProgress

    var body: some View {
        HStack(spacing: 12) {
            StatCard(title: "Points", value: "\(userProgress.totalPoints)", icon: "star.fill", color: Color.appGold)
            StatCard(
                title: "Streak",
                value: "\(userProgress.currentStreak)d",
                icon: "flame.fill",
                color: Color.appCoral,
                badge: userProgress.momentumMultiplier > 1.0 ? "2x" : nil
            )
            StatCard(title: "Best", value: "\(userProgress.longestStreak)d", icon: "trophy.fill", color: Color.appPlum)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var badge: String? = nil

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(color)
                }
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.appCoral)
                        .clipShape(Capsule())
                        .offset(x: 8, y: -4)
                }
            }
            .frame(width: 52, height: 52)

            Text(value)
                .font(.title2).fontWeight(.bold).foregroundStyle(Color.appPlum)
            Text(title)
                .font(.caption).foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}

// MARK: - Weekly Progress Chart
struct WeeklyProgressChart: View {
    let userProgress: UserProgress
    @State private var animate = false

    struct DayData: Identifiable {
        let id = UUID()
        let label: String
        let count: Int
        let date: Date
    }

    var weekData: [DayData] {
        let calendar = Calendar.current
        return (0..<7).reversed().compactMap { offset -> DayData? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return DayData(
                label: formatter.string(from: date),
                count: userProgress.completionCount(for: date),
                date: date
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("This Week")
                    .font(.title3).fontWeight(.bold).foregroundStyle(Color.appPlum)
                Spacer()
                Text("tasks per day")
                    .font(.caption).foregroundStyle(Color.appTextSecondary)
            }

            Chart(weekData) { day in
                BarMark(
                    x: .value("Day", day.label),
                    y: .value("Tasks", animate ? day.count : 0)
                )
                .foregroundStyle(
                    Calendar.current.isDateInToday(day.date)
                    ? Color.appGold.gradient
                    : Color.appPlum.opacity(0.6).gradient
                )
                .cornerRadius(6)
                .annotation(position: .top) {
                    if day.count > 0 {
                        Text("\(day.count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(Calendar.current.isDateInToday(day.date) ? Color.appGold : Color.appPlum)
                            .opacity(animate ? 1 : 0)
                    }
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(height: 120)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animate)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.06), radius: 10, y: 4)
        .onAppear {
            withAnimation { animate = true }
        }
    }
}

// MARK: - Activity Heatmap
struct ActivityHeatmap: View {
    let userProgress: UserProgress

    let columns = 10
    let rows = 7
    @State private var selectedDate: Date?

    var flatDays: [Date] {
        (0..<(columns * rows)).reversed().compactMap { i in
            Calendar.current.date(byAdding: .day, value: -i, to: Calendar.current.startOfDay(for: Date()))
        }
    }

    var weeks: [[Date]] {
        stride(from: 0, to: flatDays.count, by: rows).map { i in
            Array(flatDays[i..<min(i + rows, flatDays.count)])
        }
    }

    func cellColor(for date: Date) -> Color {
        let count = userProgress.completionCount(for: date)
        switch count {
        case 0: return Color.appPlum.opacity(0.08)
        case 1: return Color.appPlum.opacity(0.35)
        case 2: return Color.appPlum.opacity(0.6)
        case 3: return Color.appPlum.opacity(0.8)
        default: return Color.appPlum
        }
    }

    var selectedInfo: String? {
        guard let d = selectedDate else { return nil }
        let count = userProgress.completionCount(for: d)
        if count == 0 { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(count) task\(count == 1 ? "" : "s") on \(formatter.string(from: d))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Activity")
                    .font(.title3).fontWeight(.bold).foregroundStyle(Color.appPlum)
                Spacer()
                Text("Last \(columns) weeks")
                    .font(.caption).foregroundStyle(Color.appTextSecondary)
            }

            HStack(alignment: .top, spacing: 4) {
                ForEach(0..<weeks.count, id: \.self) { w in
                    VStack(spacing: 4) {
                        ForEach(0..<weeks[w].count, id: \.self) { d in
                            let day = weeks[w][d]
                            RoundedRectangle(cornerRadius: 3)
                                .fill(cellColor(for: day))
                                .frame(width: 22, height: 22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(selectedDate.map { Calendar.current.isDate($0, inSameDayAs: day) } == true
                                                ? Color.appGold : Color.clear, lineWidth: 1.5)
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        let isSame = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: day) } == true
                                        selectedDate = isSame ? nil : day
                                    }
                                }
                        }
                    }
                }
            }

            if let info = selectedInfo {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appPlum)
                    Text(info)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appPlum)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.appPlum.opacity(0.08))
                .clipShape(Capsule())
                .transition(.scale.combined(with: .opacity))
            }

            HStack {
                Text("Less")
                    .font(.caption2).foregroundStyle(Color.appTextSecondary)
                HStack(spacing: 3) {
                    ForEach([0.08, 0.35, 0.6, 1.0], id: \.self) { opacity in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.appPlum.opacity(opacity))
                            .frame(width: 12, height: 12)
                    }
                }
                Text("More")
                    .font(.caption2).foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.06), radius: 10, y: 4)
        .animation(.easeInOut(duration: 0.15), value: selectedDate)
    }
}

// MARK: - Streak Freeze Section
struct StreakFreezeSection: View {
    let userProgress: UserProgress

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 48, height: 48)
                Text("❄️")
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Streak Freezes")
                    .font(.subheadline).fontWeight(.semibold).foregroundStyle(Color.appPlum)
                Text(userProgress.streakFreezeTokens > 0
                     ? "You have \(userProgress.streakFreezeTokens) freeze\(userProgress.streakFreezeTokens == 1 ? "" : "s"). Auto-used if you miss a day."
                     : "Earn a freeze by keeping a 7-day streak.")
                    .font(.caption).foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Text("\(userProgress.streakFreezeTokens)")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(userProgress.streakFreezeTokens > 0 ? Color.blue : Color.appTextSecondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}

// MARK: - Badges Section
struct BadgesSection: View {
    let userProgress: UserProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Badges")
                .font(.title3).fontWeight(.bold).foregroundStyle(Color.appPlum)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(Badge.allCases, id: \.self) { badge in
                    BadgeCard(badge: badge, isEarned: userProgress.badges.contains(badge.rawValue))
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
                .opacity(isEarned ? 1.0 : 0.2)

            Text(badge.title)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(isEarned ? Color.appPlum : Color.appTextSecondary)

            Text(badge.description)
                .font(.caption).foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center).lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(isEarned ? Color.white : Color(red: 0.91, green: 0.95, blue: 0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isEarned ? Color.appGold : Color.clear, lineWidth: 2)
        )
        .shadow(color: isEarned ? Color.appGold.opacity(0.2) : .clear, radius: 8, y: 3)
    }
}

// MARK: - Motivational Quote
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

    var randomQuote: String { quotes.randomElement() ?? quotes[0] }

    var body: some View {
        VStack(spacing: 14) {
            Text("✦").font(.title2).foregroundStyle(Color.appGold)
            Text(randomQuote)
                .font(.title3).fontWeight(.medium).foregroundStyle(.white)
                .multilineTextAlignment(.center).lineSpacing(4)
            Text("✦").font(.title2).foregroundStyle(Color.appGold)
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
