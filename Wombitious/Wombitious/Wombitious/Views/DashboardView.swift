//
//  DashboardView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    let currentGoal: Goal?
    let userProgress: UserProgress

    @State private var showGoalCreation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Confidence Score Card
                    ConfidenceScoreCard(score: userProgress.confidenceScore)

                    if let goal = currentGoal {
                        // Current Goal Card
                        GoalProgressCard(goal: goal)

                        // Micro-targets List
                        MicroTargetsSection(goal: goal, userProgress: userProgress)
                    } else {
                        // No goal state
                        EmptyGoalState(showGoalCreation: $showGoalCreation)
                    }
                }
                .padding()
            }
            .navigationTitle("Wombitious")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showGoalCreation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showGoalCreation) {
                GoalCreationView(showGoalCreation: $showGoalCreation)
            }
        }
    }
}

struct ConfidenceScoreCard: View {
    let score: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("Confidence Score")
                .font(.headline)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold))
                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(confidenceMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    var confidenceMessage: String {
        switch score {
        case 0..<20: return "Just getting started 🌱"
        case 20..<40: return "Building momentum 🚀"
        case 40..<60: return "Making progress 💫"
        case 60..<80: return "Feeling confident 💪"
        case 80..<100: return "Crushing it! 🔥"
        default: return "You're unstoppable! ⭐️"
        }
    }
}

struct GoalProgressCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.type.icon)
                    .font(.title2)
                    .foregroundStyle(colorForType(goal.type))

                VStack(alignment: .leading) {
                    Text(goal.title)
                        .font(.headline)
                    Text(goal.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(goal.progressPercentage))%")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            ProgressView(value: goal.progressPercentage, total: 100)
                .tint(colorForType(goal.type))

            Text(goal.goalDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    func colorForType(_ type: GoalType) -> Color {
        switch type {
        case .career: return .blue
        case .education: return .purple
        case .financial: return .green
        case .personal: return .pink
        }
    }
}

struct MicroTargetsSection: View {
    @Environment(\.modelContext) private var modelContext
    let goal: Goal
    let userProgress: UserProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Action Steps")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(goal.microTargets.sorted(by: { $0.order < $1.order })) { target in
                MicroTargetRow(target: target, userProgress: userProgress)
            }
        }
    }
}

struct MicroTargetRow: View {
    @Environment(\.modelContext) private var modelContext
    let target: MicroTarget
    let userProgress: UserProgress

    var body: some View {
        HStack(spacing: 16) {
            Button {
                target.toggleCompletion()
                if target.isCompleted {
                    // Award points
                    userProgress.addPoints(10)
                    userProgress.updateStreak()

                    // Check for badges
                    checkBadges()
                }
            } label: {
                Image(systemName: target.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(target.isCompleted ? .green : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(target.title)
                    .font(.body)
                    .strikethrough(target.isCompleted)
                    .foregroundStyle(target.isCompleted ? .secondary : .primary)

                if let days = target.estimatedDays {
                    Text("~\(days) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func checkBadges() {
        // Check for first step badge
        if userProgress.badges.isEmpty {
            userProgress.addBadge(Badge.firstStep.rawValue)
        }

        // Check for streak badges
        if userProgress.currentStreak >= 7 {
            userProgress.addBadge(Badge.weekWarrior.rawValue)
        }
        if userProgress.currentStreak >= 30 {
            userProgress.addBadge(Badge.streakMaster.rawValue)
        }

        // Check confidence badge
        if userProgress.confidenceScore >= 80 {
            userProgress.addBadge(Badge.confident.rawValue)
        }
    }
}

struct EmptyGoalState: View {
    @Binding var showGoalCreation: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.pink)

            Text("Start Your Journey")
                .font(.title)
                .fontWeight(.bold)

            Text("Set your first ambitious goal and let's break it down into achievable steps.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showGoalCreation = true
            } label: {
                Text("Create Your Goal")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    DashboardView(currentGoal: nil, userProgress: UserProgress())
        .modelContainer(for: [Goal.self, UserProgress.self])
}
