//
//  GeminiService.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import Foundation

struct GeminiService {
    private let apiKey = "AIzaSyAy2QNrtRpCsf67GX1Ksl4wJcGxcAUzhg8"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

    struct MicroTargetData {
        let title: String
        let description: String
        let estimatedDays: Int?
    }

    func suggestGoalTitle(from dreamText: String) async throws -> String {
        let prompt = """
        Someone wrote this about their ideal life in one year:
        "\(dreamText)"

        Extract ONE clear, specific, actionable goal from this vision. Return ONLY the goal title, nothing else. Maximum 10 words. No quotes, no punctuation at the end.
        Example: "Land a software engineering internship at a top company"
        """

        let requestBody: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]]
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

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func generateMicroTargets(
        goalTitle: String,
        goalDescription: String,
        goalType: GoalType,
        timelineMonths: Int = 3
    ) async throws -> [MicroTargetData] {
        let prompt = buildPrompt(title: goalTitle, description: goalDescription, type: goalType, timelineMonths: timelineMonths)

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

    private func buildPrompt(title: String, description: String, type: GoalType, timelineMonths: Int) -> String {
        let totalDays = timelineMonths * 30
        let quickCutoff = max(3, totalDays / 20)       // ~5% of timeline
        let midCutoff = max(14, totalDays / 4)         // ~25% of timeline

        return """
        You are a practical goal coach helping an ambitious woman break down her \(type.rawValue.lowercased()) goal into clear, real steps.

        Goal: \(title)
        Context: \(description)
        Timeline: \(timelineMonths) month\(timelineMonths == 1 ? "" : "s") (\(totalDays) days total)

        Create exactly 7 steps spread across the FULL \(timelineMonths)-month timeline. Steps should feel like a realistic journey, not a single week's to-do list.

        TIER 1 — Quick Wins (2-3 steps, 1–\(quickCutoff) days each):
        Things to do in the first few days to build momentum.

        TIER 2 — Building Phase (2-3 steps, \(quickCutoff + 1)–\(midCutoff) days each):
        The real work — consistent actions spread across the first \(timelineMonths <= 2 ? "few weeks" : "month or two").

        TIER 3 — Big Moves (1-2 steps, \(midCutoff + 1)–\(totalDays) days each):
        Major milestones that happen in the second half of the timeline, building on everything above.

        STRICT RULES:
        - Titles must be 3–6 plain words describing the actual task. NO jargon.
        - BAD titles: "Execute the protocol", "Strategic outreach", "Asset audit", "Optimize your approach".
        - GOOD titles: "Message 5 recruiters on LinkedIn", "Meal prep for the week", "Submit 8 job applications".
        - Each step must say WHO, WHICH platform, or HOW MANY — never leave it vague.
        - Spread the days realistically — don't put everything in the first 2 weeks if the timeline is 6 months.

        Respond in this EXACT format — no intro, no extra text, just the numbered list:
        1. [Title] | [Specific description of exactly what to do] | [Days as a single integer]
        2. [Title] | [Specific description of exactly what to do] | [Days as a single integer]
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
