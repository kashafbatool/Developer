//
//  GoalCreationView.swift
//  SheRise
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData

struct GoalCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var showGoalCreation: Bool

    @State private var currentStep = 1
    @State private var dreamText = ""
    @State private var goalTitle = ""
    @State private var selectedType: GoalType?
    @State private var selectedTimeline = 3
    @State private var whyText = ""
    @State private var obstacleText = ""
    @State private var isExtractingGoal = false
    @State private var isGeneratingTargets = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    StepIndicator(currentStep: currentStep, totalSteps: 4)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    if currentStep == 1 {
                        DreamStepView(
                            dreamText: $dreamText,
                            isLoading: isExtractingGoal,
                            onContinue: extractGoal
                        )
                    } else if currentStep == 2 {
                        ReflectionStepView(
                            whyText: $whyText,
                            obstacleText: $obstacleText,
                            onContinue: { withAnimation { currentStep = 3 } }
                        )
                    } else if currentStep == 3 {
                        GoalConfirmStepView(
                            goalTitle: $goalTitle,
                            selectedType: $selectedType,
                            selectedTimeline: $selectedTimeline,
                            onContinue: createGoal,
                            isLoading: isGeneratingTargets
                        )
                    } else {
                        GeneratingStepView(
                            hasReflection: !whyText.isEmpty || !obstacleText.isEmpty
                        )
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(currentStep == 1 ? "Cancel" : "Back") {
                        if currentStep > 1 {
                            withAnimation { currentStep -= 1 }
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundStyle(Color.appPlum)
                }
            }
            .alert("Something went wrong", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    func extractGoal() {
        isExtractingGoal = true
        Task {
            do {
                let suggested = try await GeminiService().suggestGoalTitle(from: dreamText)
                await MainActor.run {
                    goalTitle = suggested
                    isExtractingGoal = false
                    withAnimation { currentStep = 2 }
                }
            } catch {
                await MainActor.run {
                    goalTitle = ""
                    isExtractingGoal = false
                    withAnimation { currentStep = 2 }
                }
            }
        }
    }

    func createGoal() {
        guard let type = selectedType, !goalTitle.isEmpty else { return }
        isGeneratingTargets = true
        withAnimation { currentStep = 4 }

        Task {
            do {
                let result = try await GeminiService().generateMicroTargets(
                    goalTitle: goalTitle,
                    goalDescription: dreamText,
                    goalType: type,
                    timelineMonths: selectedTimeline,
                    whyImportant: whyText,
                    biggestObstacle: obstacleText
                )

                let newGoal = Goal(
                    title: goalTitle,
                    description: dreamText,
                    type: type,
                    timelineMonths: selectedTimeline,
                    whyImportant: whyText,
                    biggestObstacle: obstacleText,
                    aiReasoning: result.reasoning
                )

                for (index, targetData) in result.targets.enumerated() {
                    let microTarget = MicroTarget(
                        title: targetData.title,
                        description: targetData.description,
                        order: index,
                        estimatedDays: targetData.estimatedDays
                    )
                    microTarget.goal = newGoal
                    newGoal.microTargets.append(microTarget)
                    modelContext.insert(microTarget)
                }

                modelContext.insert(newGoal)
                try modelContext.save()

                await MainActor.run {
                    showGoalCreation = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingTargets = false
                    withAnimation { currentStep = 3 }
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(step <= currentStep ? Color.appPlum : Color.appPlum.opacity(0.15))
                    .frame(height: 5)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Step 1: Dream
struct DreamStepView: View {
    @Binding var dreamText: String
    let isLoading: Bool
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("✨ Close your eyes...")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGold)
                        .fontWeight(.medium)

                    Text("It's one year from now. What does your life look like?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.appPlum)
                        .lineSpacing(4)

                    Text("Describe it as vividly as you can. Where are you? What are you doing? How do you feel?")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(3)
                }

                TextEditor(text: $dreamText)
                    .frame(minHeight: 200)
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(dreamText.isEmpty ? Color.clear : Color.appPlum.opacity(0.3), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
                    .overlay(alignment: .topLeading) {
                        if dreamText.isEmpty {
                            Text("I imagine myself...")
                                .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 24)
                                .allowsHitTesting(false)
                        }
                    }

                Button {
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView().tint(.white)
                            Text("Reading your vision...").fontWeight(.semibold)
                        } else {
                            Text("Extract My Goal").fontWeight(.semibold)
                            Image(systemName: "arrow.right").fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(dreamText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.appPlum.opacity(0.3) : Color.appPlum)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(dreamText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
            }
            .padding()
        }
    }
}

// MARK: - Step 2: Reflection
struct ReflectionStepView: View {
    @Binding var whyText: String
    @Binding var obstacleText: String
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("💭 A little about you")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGold)
                        .fontWeight(.medium)

                    Text("The more we understand, the more personal your plan will be")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color.appPlum)
                        .lineSpacing(4)

                    Text("Both questions are optional — but your answers make a real difference.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineSpacing(3)
                }

                // Question 1
                reflectionField(
                    emoji: "💜",
                    question: "Why does this goal matter to you right now?",
                    placeholder: "e.g. I want to prove to myself I can do it, or I need this for my family...",
                    text: $whyText
                )

                // Question 2
                reflectionField(
                    emoji: "🧱",
                    question: "What's your biggest obstacle?",
                    placeholder: "e.g. I don't have much free time, I struggle with confidence, I don't know where to start...",
                    text: $obstacleText
                )

                VStack(spacing: 12) {
                    Button {
                        onContinue()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("Personalise My Plan").fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.appPlum)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        onContinue()
                    } label: {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func reflectionField(emoji: String, question: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(emoji)
                Text(question)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPlum)
            }

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }
                TextEditor(text: text)
                    .font(.subheadline)
                    .frame(minHeight: 90)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(text.wrappedValue.isEmpty ? Color.appPlum.opacity(0.1) : Color.appPlum.opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        }
    }
}

// MARK: - Step 3: Confirm Goal
struct GoalConfirmStepView: View {
    @Binding var goalTitle: String
    @Binding var selectedType: GoalType?
    @Binding var selectedTimeline: Int
    let onContinue: () -> Void
    let isLoading: Bool

    let timelineOptions: [(label: String, months: Int)] = [
        ("1 month", 1), ("3 months", 3), ("6 months", 6), ("1 year", 12)
    ]

    var canContinue: Bool {
        !goalTitle.trimmingCharacters(in: .whitespaces).isEmpty && selectedType != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎯 Your goal")
                        .font(.subheadline)
                        .foregroundStyle(Color.appGold)
                        .fontWeight(.medium)

                    Text("We found this in your vision")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.appPlum)

                    Text("Edit it until it feels exactly right.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your goal")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary).textCase(.uppercase).tracking(1)
                    TextField("e.g., Land a software engineering internship", text: $goalTitle)
                        .font(.title3).fontWeight(.medium).foregroundStyle(Color.appPlum)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appPlum.opacity(0.3), lineWidth: 1.5))
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary).textCase(.uppercase).tracking(1)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            GoalTypeButton(type: type, isSelected: selectedType == type) { selectedType = type }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Timeline")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(Color.appTextSecondary).textCase(.uppercase).tracking(1)
                        Text("How long do you want to work on this goal?")
                            .font(.caption).foregroundStyle(Color.appTextSecondary)
                    }
                    HStack(spacing: 10) {
                        ForEach(timelineOptions, id: \.months) { option in
                            Button {
                                selectedTimeline = option.months
                            } label: {
                                Text(option.label).font(.subheadline).fontWeight(.medium)
                                    .foregroundStyle(selectedTimeline == option.months ? .white : Color.appPlum)
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(selectedTimeline == option.months ? Color.appPlum : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedTimeline == option.months ? Color.clear : Color.appPlum.opacity(0.2), lineWidth: 1))
                                    .shadow(color: selectedTimeline == option.months ? Color.appPlum.opacity(0.2) : .black.opacity(0.03), radius: 4, y: 2)
                            }
                        }
                    }
                }

                Button {
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Generate My Action Steps").fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(canContinue ? Color.appPlum : Color.appPlum.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canContinue)
            }
            .padding()
        }
    }
}

// MARK: - Step 4: Generating
struct GeneratingStepView: View {
    let hasReflection: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle().fill(Color.appPlum.opacity(0.07)).frame(width: 160, height: 160)
                Circle().fill(Color.appPlum.opacity(0.1)).frame(width: 120, height: 120)
                Text("✨").font(.system(size: 52))
            }

            VStack(spacing: 12) {
                Text("Building your plan...")
                    .font(.title2).fontWeight(.bold).foregroundStyle(Color.appPlum)

                Text(hasReflection
                     ? "Personalising your steps based on what you shared..."
                     : "Turning your dream into actionable steps just for you")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            ProgressView().tint(Color.appGold).scaleEffect(1.5)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Goal Type Button
struct GoalTypeButton: View {
    let type: GoalType
    let isSelected: Bool
    let action: () -> Void

    var colorForType: Color {
        switch type {
        case .career: return .blue
        case .education: return .purple
        case .financial: return .green
        case .personal: return Color.appCoral
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? .white.opacity(0.2) : colorForType.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : colorForType)
                }
                Text(type.rawValue)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : Color.appPlum)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 18)
            .background(isSelected ? Color.appPlum : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.clear : Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1))
            .shadow(color: isSelected ? Color.appPlum.opacity(0.25) : .black.opacity(0.04), radius: 8, y: 3)
        }
    }
}

#Preview {
    GoalCreationView(showGoalCreation: .constant(true))
        .modelContainer(for: Goal.self)
}
