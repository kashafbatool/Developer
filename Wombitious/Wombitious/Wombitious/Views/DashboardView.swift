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
    @State private var showCheckIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        GreetingHeader(energyLevel: userProgress.todayEnergyLevel)
                        ConfidenceScoreCard(score: userProgress.confidenceScore)

                        if let goal = currentGoal {
                            GoalProgressCard(goal: goal)
                            MicroTargetsSection(goal: goal, userProgress: userProgress)
                        } else {
                            EmptyGoalState(showGoalCreation: $showGoalCreation)
                        }
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showGoalCreation = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPlum)
                            .padding(8)
                            .background(Color.appPlum.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showGoalCreation) {
                GoalCreationView(showGoalCreation: $showGoalCreation)
            }
            .sheet(isPresented: $showCheckIn) {
                EnergyCheckInView(showCheckIn: $showCheckIn, userProgress: userProgress)
            }
            .onAppear {
                if userProgress.needsDailyCheckIn {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCheckIn = true
                    }
                }
            }
        }
    }
}

struct GreetingHeader: View {
    let energyLevel: Int

    var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var energyMessage: String {
        switch energyLevel {
        case 1: return "Be gentle with yourself today 🌿"
        case 2: return "Small steps still count 💛"
        case 3: return "Steady progress wins 🙂"
        case 4: return "You're in a great place 💪"
        case 5: return "Today is yours to own 🔥"
        default: return "Ready to make progress? ✨"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(timeGreeting)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                Text("Wombitious")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)
                Text(energyMessage)
                    .font(.caption)
                    .foregroundStyle(Color.appGold)
                    .fontWeight(.medium)
            }
            Spacer()
        }
    }
}

struct ConfidenceScoreCard: View {
    let score: Int

    var body: some View {
        HStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.appGold.opacity(0.2), lineWidth: 10)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(Color.appGold, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.appPlum)
                    Text("/ 100")
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Confidence Score")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)

                Text(confidenceMessage)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPlum)

                Text("Complete steps to grow your score")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.08), radius: 12, y: 4)
    }

    var confidenceMessage: String {
        switch score {
        case 0..<20: return "Just starting 🌱"
        case 20..<40: return "Building up 🚀"
        case 40..<60: return "In progress 💫"
        case 60..<80: return "Confident 💪"
        case 80..<100: return "Crushing it 🔥"
        default: return "Unstoppable ⭐️"
        }
    }
}

struct GoalProgressCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: goal.type.icon)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(goal.type.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())

                Spacer()

                Text("\(Int(goal.progressPercentage))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appGold)
            }

            Text(goal.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(goal.goalDescription)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(2)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.2))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appGold)
                        .frame(width: geo.size.width * CGFloat(goal.progressPercentage / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(20)
        .background(Color.appPlum)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.3), radius: 12, y: 6)
    }
}

struct MicroTargetsSection: View {
    @Environment(\.modelContext) private var modelContext
    let goal: Goal
    let userProgress: UserProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Your Action Steps")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)

                Spacer()

                Text("\(goal.microTargets.filter(\.isCompleted).count)/\(goal.microTargets.count) done")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

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
        HStack(spacing: 14) {
            Button {
                target.toggleCompletion()
                if target.isCompleted {
                    userProgress.addPoints(10)
                    userProgress.updateStreak()
                    checkBadges()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(target.isCompleted ? Color.appGold : Color.appPlum.opacity(0.08))
                        .frame(width: 32, height: 32)

                    if target.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .stroke(Color.appPlum.opacity(0.3), lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(target.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(target.isCompleted)
                    .foregroundStyle(target.isCompleted ? Color.appTextSecondary : Color.appPlum)

                if let days = target.estimatedDays {
                    Text("~\(days) days")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(target.isCompleted ? Color.appGold.opacity(0.08) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    func checkBadges() {
        if userProgress.badges.isEmpty {
            userProgress.addBadge(Badge.firstStep.rawValue)
        }
        if userProgress.currentStreak >= 7 {
            userProgress.addBadge(Badge.weekWarrior.rawValue)
        }
        if userProgress.currentStreak >= 30 {
            userProgress.addBadge(Badge.streakMaster.rawValue)
        }
        if userProgress.confidenceScore >= 80 {
            userProgress.addBadge(Badge.confident.rawValue)
        }
    }
}

struct EmptyGoalState: View {
    @Binding var showGoalCreation: Bool

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.appPlum.opacity(0.07))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(Color.appPlum.opacity(0.05))
                    .frame(width: 110, height: 110)
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appGold)
            }

            VStack(spacing: 10) {
                Text("Your Journey Starts Here")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)

                Text("Set your first ambitious goal and let AI break it down into steps you can actually achieve.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                showGoalCreation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Create Your First Goal")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appPlum)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    DashboardView(currentGoal: nil, userProgress: UserProgress())
        .modelContainer(for: [Goal.self, UserProgress.self])
}
