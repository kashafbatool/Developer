//
//  GeminiService.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation

struct GeminiService {
    // TODO: Add your Gemini API key here
    private let apiKey = "YOUR_GEMINI_API_KEY_HERE"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"

    struct MicroTargetData {
        let title: String
        let description: String
        let estimatedDays: Int?
    }

    func generateMicroTargets(
        goalTitle: String,
        goalDescription: String,
        goalType: GoalType
    ) async throws -> [MicroTargetData] {
        let prompt = buildPrompt(title: goalTitle, description: goalDescription, type: goalType)

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: URL(string: "\(apiURL)?key=\(apiKey)")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GeminiError.invalidResponse
        }

        let result = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let text = result.candidates.first?.content.parts.first?.text else {
            throw GeminiError.noContent
        }

        return parseMicroTargets(from: text)
    }

    private func buildPrompt(title: String, description: String, type: GoalType) -> String {
        """
        You are a goal-setting coach helping an ambitious woman achieve her \(type.rawValue.lowercased()) goal.

        Goal: \(title)
        Description: \(description)

        Break this goal down into 5-7 specific, actionable micro-targets that will help her achieve this goal. Each micro-target should:
        - Be concrete and measurable
        - Build progressively (start with easier steps, advance to harder ones)
        - Be achievable within days or weeks, not months
        - Include an estimated number of days to complete

        Format your response EXACTLY as follows (one target per line):
        1. [Target Title] | [Detailed description of what to do] | [Estimated days]
        2. [Target Title] | [Detailed description of what to do] | [Estimated days]
        ...

        Example format:
        1. Research companies | Look up 10-15 companies in your field that offer internships and create a spreadsheet with their application deadlines | 3
        2. Update resume | Tailor your resume to highlight relevant skills and experiences for software engineering roles | 2

        Now provide 5-7 micro-targets for the goal described above:
        """
    }

    private func parseMicroTargets(from text: String) -> [MicroTargetData] {
        var targets: [MicroTargetData] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            // Look for lines starting with a number
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.first?.isNumber == true else { continue }

            // Remove the number prefix (e.g., "1. " or "1) ")
            var content = trimmed
            if let dotIndex = content.firstIndex(of: ".") ?? content.firstIndex(of: ")") {
                content = String(content[content.index(after: dotIndex)...]).trimmingCharacters(in: .whitespaces)
            }

            // Split by pipes
            let parts = content.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }

            if parts.count >= 2 {
                let title = parts[0]
                let description = parts[1]
                let estimatedDays = parts.count >= 3 ? Int(parts[2].filter { $0.isNumber }) : nil

                targets.append(MicroTargetData(
                    title: title,
                    description: description,
                    estimatedDays: estimatedDays
                ))
            }
        }

        // If parsing failed, provide fallback targets
        if targets.isEmpty {
            targets = getFallbackTargets()
        }

        return targets
    }

    private func getFallbackTargets() -> [MicroTargetData] {
        [
            MicroTargetData(
                title: "Research and Define Your Goal",
                description: "Spend time researching what it takes to achieve this goal and clarify your specific target.",
                estimatedDays: 3
            ),
            MicroTargetData(
                title: "Create an Action Plan",
                description: "List out the major steps you'll need to take and organize them in order.",
                estimatedDays: 2
            ),
            MicroTargetData(
                title: "Take the First Step",
                description: "Complete the very first action toward your goal, no matter how small.",
                estimatedDays: 1
            ),
            MicroTargetData(
                title: "Build Momentum",
                description: "Continue with the next 2-3 actions consistently to establish a routine.",
                estimatedDays: 7
            ),
            MicroTargetData(
                title: "Review and Adjust",
                description: "Check your progress and adjust your approach based on what you've learned.",
                estimatedDays: 1
            )
        ]
    }
}

enum GeminiError: LocalizedError {
    case invalidResponse
    case noContent

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Failed to get a valid response from the AI service"
        case .noContent:
            return "No content received from the AI service"
        }
    }
}

// MARK: - Response Models
struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}
