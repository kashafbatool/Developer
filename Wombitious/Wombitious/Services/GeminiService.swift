//
//  GeminiService.swift
//  SheRise
//
//  Created by Kashaf Batool
//

import Foundation

struct GeminiService {
    private let apiKey = "YOUR_GEMINI_API_KEY_HERE"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"

    struct MicroTargetData {
        let title: String
        let description: String
        let estimatedDays: Int?
    }

    struct GenerationResult {
        let targets: [MicroTargetData]
        let reasoning: String
    }

    // MARK: - Extract goal title from dream text
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

    // MARK: - Generate personalised steps + reasoning
    func generateMicroTargets(
        goalTitle: String,
        goalDescription: String,
        goalType: GoalType,
        timelineMonths: Int = 3,
        whyImportant: String = "",
        biggestObstacle: String = ""
    ) async throws -> GenerationResult {
        let prompt = buildPrompt(
            title: goalTitle,
            description: goalDescription,
            type: goalType,
            timelineMonths: timelineMonths,
            whyImportant: whyImportant,
            biggestObstacle: biggestObstacle
        )

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

        return parseGenerationResult(from: text, obstacle: biggestObstacle, why: whyImportant)
    }

    // MARK: - Prompt builder
    private func buildPrompt(
        title: String,
        description: String,
        type: GoalType,
        timelineMonths: Int,
        whyImportant: String,
        biggestObstacle: String
    ) -> String {
        let totalDays = timelineMonths * 30
        let quickCutoff = max(3, totalDays / 20)
        let midCutoff = max(14, totalDays / 4)

        let whySection = whyImportant.trimmingCharacters(in: .whitespaces).isEmpty
            ? ""
            : "\nWhy this goal matters to them: \"\(whyImportant)\""

        let obstacleSection = biggestObstacle.trimmingCharacters(in: .whitespaces).isEmpty
            ? ""
            : "\nTheir biggest obstacle: \"\(biggestObstacle)\""

        return """
        You are a practical goal coach helping an ambitious woman break down her \(type.rawValue.lowercased()) goal into clear, personal steps.

        Goal: \(title)
        Their vision: \(description)\(whySection)\(obstacleSection)
        Timeline: \(timelineMonths) month\(timelineMonths == 1 ? "" : "s") (\(totalDays) days total)

        \(!biggestObstacle.isEmpty || !whyImportant.isEmpty ? "Use their WHY and OBSTACLE to shape the steps — make them feel like they were written specifically for this person, not copy-pasted from a generic list." : "")

        Create exactly 7 steps spread across the FULL \(timelineMonths)-month timeline.

        TIER 1 — Quick Wins (2-3 steps, 1–\(quickCutoff) days each): Things to do in the first few days to build momentum.\(!biggestObstacle.isEmpty ? " Since their obstacle is '\(biggestObstacle)', make these especially low-friction and achievable." : "")

        TIER 2 — Building Phase (2-3 steps, \(quickCutoff + 1)–\(midCutoff) days each): The real work — consistent actions spread across the first \(timelineMonths <= 2 ? "few weeks" : "month or two").

        TIER 3 — Big Moves (1-2 steps, \(midCutoff + 1)–\(totalDays) days each): Major milestones in the second half, building on everything above.

        STRICT RULES:
        - Titles must be 3–6 plain words. NO jargon.
        - BAD: "Execute the protocol", "Strategic outreach", "Asset audit".
        - GOOD: "Message 5 recruiters on LinkedIn", "Meal prep Sunday", "Submit 8 job applications".
        - Each step must say WHO, WHICH platform, or HOW MANY — never vague.

        CRITICAL: Start your response with EXACTLY this line (fill in the blank):
        REASONING: [1-2 sentences starting with "Since you said..." that reference their WHY or OBSTACLE and explain why these specific steps were designed for them. If no WHY or OBSTACLE was given, write a sentence about how the steps are paced for the timeline.]

        Then immediately list the 7 steps:
        1. [Title] | [Specific description of exactly what to do] | [Days as a single integer]
        2. [Title] | [Specific description of exactly what to do] | [Days as a single integer]
        """
    }

    // MARK: - Response parser
    private func parseGenerationResult(from text: String, obstacle: String, why: String) -> GenerationResult {
        var reasoning = ""
        var stepsText = text

        // Extract REASONING line
        let lines = text.components(separatedBy: .newlines)
        var stepLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("REASONING:") {
                reasoning = String(trimmed.dropFirst("REASONING:".count))
                    .trimmingCharacters(in: .whitespaces)
            } else {
                stepLines.append(line)
            }
        }

        stepsText = stepLines.joined(separator: "\n")

        // Fallback reasoning if AI didn't include one
        if reasoning.isEmpty {
            if !obstacle.isEmpty {
                reasoning = "Since your biggest obstacle is \"\(obstacle)\", the early steps are designed to be quick and low-friction so you can build confidence before the bigger challenges."
            } else if !why.isEmpty {
                reasoning = "Because this goal matters to you for a personal reason, the steps are paced to keep motivation high throughout the full timeline."
            } else {
                reasoning = "These steps are spread across your full timeline to build momentum early and save the bigger milestones for when you have more confidence and momentum."
            }
        }

        let targets = parseMicroTargets(from: stepsText)
        return GenerationResult(targets: targets, reasoning: reasoning)
    }

    private func parseMicroTargets(from text: String) -> [MicroTargetData] {
        var targets: [MicroTargetData] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.first?.isNumber == true else { continue }

            var content = trimmed
            if let dotIndex = content.firstIndex(of: ".") ?? content.firstIndex(of: ")") {
                content = String(content[content.index(after: dotIndex)...]).trimmingCharacters(in: .whitespaces)
            }

            let parts = content.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }

            if parts.count >= 2 {
                targets.append(MicroTargetData(
                    title: parts[0],
                    description: parts[1],
                    estimatedDays: parts.count >= 3 ? Int(parts[2].filter { $0.isNumber }) : nil
                ))
            }
        }

        return targets.isEmpty ? getFallbackTargets() : targets
    }

    private func getFallbackTargets() -> [MicroTargetData] {
        [
            MicroTargetData(title: "Research and Define Your Goal", description: "Spend time researching what it takes to achieve this goal and clarify your specific target.", estimatedDays: 3),
            MicroTargetData(title: "Create an Action Plan", description: "List out the major steps you'll need to take and organise them in order.", estimatedDays: 2),
            MicroTargetData(title: "Take the First Step", description: "Complete the very first action toward your goal, no matter how small.", estimatedDays: 1),
            MicroTargetData(title: "Build Momentum", description: "Continue with the next 2-3 actions consistently to establish a routine.", estimatedDays: 7),
            MicroTargetData(title: "Review and Adjust", description: "Check your progress and adjust your approach based on what you've learned.", estimatedDays: 1)
        ]
    }
}

enum GeminiError: LocalizedError {
    case invalidResponse
    case noContent

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Failed to get a valid response from the AI service"
        case .noContent:       return "No content received from the AI service"
        }
    }
}

// MARK: - Response Models
struct GeminiResponse: Codable { let candidates: [Candidate] }
struct Candidate: Codable     { let content: Content }
struct Content: Codable       { let parts: [Part] }
struct Part: Codable          { let text: String }
