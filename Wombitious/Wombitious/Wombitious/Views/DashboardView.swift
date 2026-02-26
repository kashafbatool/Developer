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
    let goals: [Goal]
    let userProgress: UserProgress

    @State private var showGoalCreation = false
    @State private var showCheckIn = false
    @State private var completedGoal: Goal?
    @State private var lockedFocusID: UUID?

    var activeGoals: [Goal] { goals.filter { !$0.isCompleted } }

    var todaysFocus: (goal: Goal, target: MicroTarget)? {
        for goal in activeGoals {
            if let target = goal.microTargets
                .sorted(by: { $0.order < $1.order })
                .first(where: { !$0.isCompleted }) {
                return (goal, target)
            }
        }
        return nil
    }

    // Locked focus — stays pinned to the target shown at session start
    var lockedFocusPair: (goal: Goal, target: MicroTarget)? {
        guard let id = lockedFocusID else { return nil }
        for goal in activeGoals + goals.filter({ $0.isCompleted }) {
            if let t = goal.microTargets.first(where: { $0.id == id }) {
                return (goal, t)
            }
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        GreetingHeader(energyLevel: userProgress.todayEnergyLevel)

                        if userProgress.momentumMultiplier > 1.0 {
                            MomentumBanner(streak: userProgress.currentStreak)
                        }

                        ConfidenceScoreCard(score: userProgress.confidenceScore)

                        if let focus = lockedFocusPair {
                            TodaysFocusCard(
                                goal: focus.goal,
                                target: focus.target,
                                userProgress: userProgress,
                                onComplete: { checkGoalCompletion(focus.goal) }
                            )
                        }

                        if activeGoals.isEmpty && !goals.isEmpty {
                            AllGoalsDoneState()
                        } else if activeGoals.isEmpty {
                            EmptyGoalState(showGoalCreation: $showGoalCreation)
                        } else {
                            ForEach(activeGoals) { goal in
                                GoalProgressCard(goal: goal)
                                MicroTargetsSection(
                                    goal: goal,
                                    userProgress: userProgress,
                                    onGoalComplete: { completedGoal = $0 }
                                )
                            }
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
            .sheet(item: $completedGoal) { goal in
                GoalCompletionView(goal: goal, userProgress: userProgress) {
                    completedGoal = nil
                }
            }
            .onAppear {
                lockFocusIfNeeded()
                if userProgress.needsDailyCheckIn {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCheckIn = true
                    }
                }
            }
            .onChange(of: goals.count) { _, _ in
                lockFocusIfNeeded()
            }
        }
    }

    private func lockFocusIfNeeded() {
        if lockedFocusID == nil {
            lockedFocusID = todaysFocus?.target.id
        }
    }

    func checkGoalCompletion(_ goal: Goal) {
        if goal.microTargets.allSatisfy(\.isCompleted) {
            goal.isCompleted = true
            userProgress.addBadge(Badge.goalCrusher.rawValue)
            completedGoal = goal
        }
    }
}

// MARK: - Momentum Banner
struct MomentumBanner: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 10) {
            Text("🔥")
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("2x Momentum Active!")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)
                Text("\(streak)-day streak — every step earns double points")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.appGold.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appGold.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Today's Focus Card
struct TodaysFocusCard: View {
    @Environment(\.modelContext) private var modelContext
    let goal: Goal
    let target: MicroTarget
    let userProgress: UserProgress
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("TODAY'S FOCUS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appGold)
                    .tracking(1.5)
                Spacer()
                Text(goal.title)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }

            if target.isCompleted {
                // Done-for-today state — don't auto-advance
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.appGold.opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.appGold)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(target.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .strikethrough()
                                .foregroundStyle(Color.appTextSecondary)
                            Text("Completed today")
                                .font(.caption)
                                .foregroundStyle(Color.appGold)
                        }
                        Spacer()
                    }
                    Text("Great work! Come back tomorrow for your next step.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(target.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)

                if !target.targetDescription.isEmpty {
                    Text(target.targetDescription)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(3)
                        .lineSpacing(3)
                }

                Button {
                    target.toggleCompletion()
                    if target.isCompleted {
                        userProgress.addPoints(10)
                        userProgress.updateStreak()
                        onComplete()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "circle")
                            .foregroundStyle(Color.appPlum)
                        Text("Mark complete")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPlum)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appPlum.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appPlum.opacity(0.1), radius: 12, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(target.isCompleted ? Color.appGold.opacity(0.4) : Color.appGold.opacity(0.3), lineWidth: 1.5)
        )
    }
}

// MARK: - Greeting Header
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

// MARK: - Confidence Score Card
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

// MARK: - Goal Progress Card
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

// MARK: - Micro Targets Section
struct MicroTargetsSection: View {
    @Environment(\.modelContext) private var modelContext
    let goal: Goal
    let userProgress: UserProgress
    let onGoalComplete: (Goal) -> Void

    var totalDays: Int { goal.timelineMonths * 30 }
    var quickCutoff: Int { max(3, totalDays / 20) }
    var midCutoff: Int { max(14, totalDays / 4) }

    var sortedTargets: [MicroTarget] {
        goal.microTargets.sorted(by: { $0.order < $1.order })
    }

    var quickWins: [MicroTarget] {
        sortedTargets.filter { ($0.estimatedDays ?? 9999) <= quickCutoff }
    }

    var buildingPhase: [MicroTarget] {
        sortedTargets.filter { let d = $0.estimatedDays ?? 9999; return d > quickCutoff && d <= midCutoff }
    }

    var bigMoves: [MicroTarget] {
        sortedTargets.filter { ($0.estimatedDays ?? 9999) > midCutoff }
    }

    var buildingLabel: String {
        goal.timelineMonths <= 1 ? "This Week" : goal.timelineMonths <= 3 ? "This Month" : "Building Phase"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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

            if !quickWins.isEmpty {
                targetGroup(emoji: "⚡️", label: "Quick Wins", sublabel: "first \(quickCutoff) days", targets: quickWins)
            }
            if !buildingPhase.isEmpty {
                targetGroup(emoji: "📅", label: buildingLabel, sublabel: "\(quickCutoff + 1)–\(midCutoff) days", targets: buildingPhase)
            }
            if !bigMoves.isEmpty {
                targetGroup(emoji: "🏆", label: "Big Moves", sublabel: "\(midCutoff + 1)+ days", targets: bigMoves)
            }

            if quickWins.isEmpty && buildingPhase.isEmpty && bigMoves.isEmpty {
                ForEach(sortedTargets) { target in
                    MicroTargetRow(target: target, goal: goal, userProgress: userProgress, onGoalComplete: onGoalComplete)
                }
            }
        }
    }

    @ViewBuilder
    func targetGroup(emoji: String, label: String, sublabel: String, targets: [MicroTarget]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(emoji).font(.caption)
                Text(label)
                    .font(.subheadline).fontWeight(.bold).foregroundStyle(Color.appPlum)
                Text("·  \(sublabel)")
                    .font(.caption).foregroundStyle(Color.appTextSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.appPlum.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            ForEach(targets) { target in
                MicroTargetRow(target: target, goal: goal, userProgress: userProgress, onGoalComplete: onGoalComplete)
            }
        }
    }
}

// MARK: - Micro Target Row
struct MicroTargetRow: View {
    @Environment(\.modelContext) private var modelContext
    let target: MicroTarget
    let goal: Goal
    let userProgress: UserProgress
    let onGoalComplete: (Goal) -> Void
    @State private var showConfetti = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Button {
                    let wasCompleted = target.isCompleted
                    target.toggleCompletion()
                    if !wasCompleted && target.isCompleted {
                        userProgress.addPoints(10)
                        userProgress.updateStreak()
                        checkBadges()
                        showConfetti = true
                        if goal.microTargets.allSatisfy(\.isCompleted) {
                            goal.isCompleted = true
                            userProgress.addBadge(Badge.goalCrusher.rawValue)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                onGoalComplete(goal)
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(target.isCompleted ? Color.appGold : Color.appPlum.opacity(0.08))
                            .frame(width: 32, height: 32)
                        if target.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.caption).fontWeight(.bold).foregroundStyle(.white)
                        } else {
                            Circle()
                                .stroke(Color.appPlum.opacity(0.3), lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }
                    }
                }

                if showConfetti {
                    ConfettiView(onFinish: { showConfetti = false })
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(target.title)
                    .font(.subheadline).fontWeight(.medium)
                    .strikethrough(target.isCompleted)
                    .foregroundStyle(target.isCompleted ? Color.appTextSecondary : Color.appPlum)

                if let days = target.estimatedDays {
                    Text("~\(days) days")
                        .font(.caption).foregroundStyle(Color.appTextSecondary)
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
        if userProgress.badges.isEmpty { userProgress.addBadge(Badge.firstStep.rawValue) }
        if userProgress.currentStreak >= 7 { userProgress.addBadge(Badge.weekWarrior.rawValue) }
        if userProgress.currentStreak >= 30 { userProgress.addBadge(Badge.streakMaster.rawValue) }
        if userProgress.confidenceScore >= 80 { userProgress.addBadge(Badge.confident.rawValue) }
    }
}

// MARK: - Confetti
struct ConfettiView: View {
    let onFinish: () -> Void
    @State private var animate = false
    private let confettiColors: [Color] = [.appPlum, .appGold, .appCoral, .blue, .green, .pink]

    var body: some View {
        ZStack {
            ForEach(0..<24, id: \.self) { i in
                confettiPiece(index: i)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { animate = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { onFinish() }
        }
    }

    @ViewBuilder
    func confettiPiece(index: Int) -> some View {
        let angle = Double(index) / 24.0 * 2 * .pi
        let dist: CGFloat = index % 2 == 0 ? 90 : 120
        RoundedRectangle(cornerRadius: 2)
            .fill(confettiColors[index % confettiColors.count])
            .frame(width: 8, height: 5)
            .offset(x: animate ? CGFloat(cos(angle)) * dist : 0, y: animate ? CGFloat(sin(angle)) * dist - 20 : 0)
            .rotationEffect(.degrees(animate ? Double(index * 45) : 0))
            .opacity(animate ? 0 : 1)
    }
}

// MARK: - Empty states
struct AllGoalsDoneState: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🏆")
                .font(.system(size: 64))
            Text("All goals complete!")
                .font(.title2).fontWeight(.bold).foregroundStyle(Color.appPlum)
            Text("You're on a roll. Add a new goal to keep the momentum going.")
                .font(.subheadline).foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct EmptyGoalState: View {
    @Binding var showGoalCreation: Bool

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle().fill(Color.appPlum.opacity(0.07)).frame(width: 140, height: 140)
                Circle().fill(Color.appPlum.opacity(0.05)).frame(width: 110, height: 110)
                Image(systemName: "star.circle.fill").font(.system(size: 64)).foregroundStyle(Color.appGold)
            }

            VStack(spacing: 10) {
                Text("Your Journey Starts Here")
                    .font(.title2).fontWeight(.bold).foregroundStyle(Color.appPlum)
                Text("Set your first ambitious goal and let AI break it down into steps you can actually achieve.")
                    .font(.subheadline).foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center).padding(.horizontal)
            }

            Button {
                showGoalCreation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Create Your First Goal").fontWeight(.semibold)
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
    DashboardView(goals: [], userProgress: UserProgress())
        .modelContainer(for: [Goal.self, UserProgress.self])
}
