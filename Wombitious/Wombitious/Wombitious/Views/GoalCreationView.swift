//
//  GoalCreationView.swift
//  Wombitious
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
    @State private var isExtractingGoal = false
    @State private var isGeneratingTargets = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Step indicator
                    StepIndicator(currentStep: currentStep, totalSteps: 3)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Step content
                    if currentStep == 1 {
                        DreamStepView(
                            dreamText: $dreamText,
                            isLoading: isExtractingGoal,
                            onContinue: extractGoal
                        )
                    } else if currentStep == 2 {
                        GoalConfirmStepView(
                            goalTitle: $goalTitle,
                            selectedType: $selectedType,
                            onContinue: createGoal,
                            isLoading: isGeneratingTargets
                        )
                    } else {
                        GeneratingStepView()
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
                let geminiService = GeminiService()
                let suggested = try await geminiService.suggestGoalTitle(from: dreamText)
                await MainActor.run {
                    goalTitle = suggested
                    isExtractingGoal = false
                    withAnimation { currentStep = 2 }
                }
            } catch {
                await MainActor.run {
                    // If extraction fails, just move to step 2 with empty field
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
        withAnimation { currentStep = 3 }

        Task {
            do {
                let geminiService = GeminiService()
                let generatedTargets = try await geminiService.generateMicroTargets(
                    goalTitle: goalTitle,
                    goalDescription: dreamText,
                    goalType: type
                )

                let newGoal = Goal(title: goalTitle, description: dreamText, type: type)

                for (index, targetData) in generatedTargets.enumerated() {
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
                    withAnimation { currentStep = 2 }
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
                            Text("Reading your vision...")
                                .fontWeight(.semibold)
                        } else {
                            Text("Extract My Goal")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .fontWeight(.semibold)
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

// MARK: - Step 2: Confirm Goal
struct GoalConfirmStepView: View {
    @Binding var goalTitle: String
    @Binding var selectedType: GoalType?
    let onContinue: () -> Void
    let isLoading: Bool

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
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)
                        .textCase(.uppercase)
                        .tracking(1)

                    TextField("e.g., Land a software engineering internship", text: $goalTitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appPlum)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.appPlum.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Category")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appTextSecondary)
                        .textCase(.uppercase)
                        .tracking(1)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            GoalTypeButton(type: type, isSelected: selectedType == type) {
                                selectedType = type
                            }
                        }
                    }
                }

                Button {
                    onContinue()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Generate My Action Steps")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(canContinue ? Color.appPlum : Color.appPlum.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canContinue)
            }
            .padding()
        }
    }
}

// MARK: - Step 3: Generating
struct GeneratingStepView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appPlum.opacity(0.07))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(Color.appPlum.opacity(0.1))
                    .frame(width: 120, height: 120)
                Text("✨")
                    .font(.system(size: 52))
            }

            VStack(spacing: 12) {
                Text("Creating your plan...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)

                Text("We're turning your dream into\nactionable steps just for you")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            ProgressView()
                .tint(Color.appGold)
                .scaleEffect(1.5)

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
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : Color.appPlum)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isSelected ? Color.appPlum : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.appPlum.opacity(0.25) : .black.opacity(0.04), radius: 8, y: 3)
        }
    }

    var colorForType: Color {
        switch type {
        case .career: return .blue
        case .education: return .purple
        case .financial: return .green
        case .personal: return Color.appCoral
        }
    }
}

#Preview {
    GoalCreationView(showGoalCreation: .constant(true))
        .modelContainer(for: Goal.self)
}
