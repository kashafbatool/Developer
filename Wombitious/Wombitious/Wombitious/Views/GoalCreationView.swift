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

    @State private var selectedType: GoalType?
    @State private var goalTitle = ""
    @State private var goalDescription = ""
    @State private var isGeneratingTargets = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Goal Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What type of goal is this?")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(GoalType.allCases, id: \.self) { type in
                                GoalTypeButton(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                    }

                    // Goal Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Goal Title")
                            .font(.headline)
                        TextField("e.g., Get a software engineering internship", text: $goalTitle)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Goal Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Describe Your Goal")
                            .font(.headline)
                        Text("Be specific! The more details you provide, the better we can help you break it down.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $goalDescription)
                            .frame(height: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Create Button
                    Button {
                        createGoal()
                    } label: {
                        if isGeneratingTargets {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Goal & Generate Steps")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canCreate ? LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(!canCreate || isGeneratingTargets)
                }
                .padding()
            }
            .navigationTitle("Create Your Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    var canCreate: Bool {
        selectedType != nil && !goalTitle.isEmpty && !goalDescription.isEmpty
    }

    func createGoal() {
        guard let type = selectedType else { return }

        isGeneratingTargets = true

        Task {
            do {
                // Call Gemini API to generate micro-targets
                let geminiService = GeminiService()
                let generatedTargets = try await geminiService.generateMicroTargets(
                    goalTitle: goalTitle,
                    goalDescription: goalDescription,
                    goalType: type
                )

                // Create goal
                let newGoal = Goal(
                    title: goalTitle,
                    description: goalDescription,
                    type: type
                )

                // Add micro-targets
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
                    isGeneratingTargets = false
                    showGoalCreation = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingTargets = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct GoalTypeButton: View {
    let type: GoalType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title)
                Text(type.rawValue)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? colorForType : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    var colorForType: Color {
        switch type {
        case .career: return .blue
        case .education: return .purple
        case .financial: return .green
        case .personal: return .pink
        }
    }
}

#Preview {
    GoalCreationView(showGoalCreation: .constant(true))
        .modelContainer(for: Goal.self)
}
