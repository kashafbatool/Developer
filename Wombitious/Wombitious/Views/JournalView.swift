//
//  JournalView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData
import TipKit

// MARK: - Tape style definitions
private let tapeColors: [Color] = [
    Color(red: 0.98, green: 0.82, blue: 0.55),  // amber-warm (appGold tint)
    Color(red: 0.78, green: 0.92, blue: 0.82),  // light sage green
    Color(red: 0.72, green: 0.88, blue: 0.76),  // soft mint green
    Color(red: 0.90, green: 0.95, blue: 0.72),  // yellow-green
    Color(red: 0.63, green: 0.84, blue: 0.72),  // medium sage
]
private let tapeRotations: [Double] = [-4, 5, -6, 3, -3]
private let tapeWidths: [CGFloat] = [52, 44, 56, 48, 50]

// Cream paper color
private let paperColor = Color(red: 0.99, green: 0.97, blue: 0.92)

struct JournalView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Environment(\.modelContext) private var modelContext

    @State private var showNewEntry = false
    @State private var showStarredOnly = false
    private let journalTip = JournalTip()

    var displayedEntries: [JournalEntry] {
        showStarredOnly ? entries.filter(\.isStarred) : entries
    }

    var body: some View {
        NavigationStack {
            ZStack {
                paperColor.ignoresSafeArea()

                if displayedEntries.isEmpty {
                    JournalEmptyState(showNewEntry: $showNewEntry, showStarredOnly: showStarredOnly)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            TipView(journalTip, arrowEdge: .top)
                                .tipBackground(Color(red: 0.96, green: 0.93, blue: 0.87))
                                .padding(.top, 4)
                            ForEach(displayedEntries) { entry in
                                JournalEntryCard(entry: entry)
                                    .contextMenu {
                                        Button {
                                            entry.isStarred.toggle()
                                        } label: {
                                            Label(entry.isStarred ? "Unstar" : "Star",
                                                  systemImage: entry.isStarred ? "star.slash" : "star.fill")
                                        }
                                        Button(role: .destructive) {
                                            modelContext.delete(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Journal")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbarBackground(paperColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appPlum)
                            .padding(8)
                            .background(Color.appPlum.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Write new journal entry")
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation { showStarredOnly.toggle() }
                    } label: {
                        Image(systemName: showStarredOnly ? "star.fill" : "star")
                            .foregroundStyle(showStarredOnly ? Color.appGold : Color.appTextSecondary)
                    }
                    .accessibilityLabel(showStarredOnly ? "Show all entries" : "Show starred entries only")
                }
            }
            .sheet(isPresented: $showNewEntry) {
                NewJournalEntrySheet()
            }
        }
    }
}

// MARK: - Entry Card
struct JournalEntryCard: View {
    let entry: JournalEntry

    var tapeColor: Color { tapeColors[entry.tapeStyle % tapeColors.count] }
    var tapeRotation: Double { tapeRotations[entry.tapeStyle % tapeRotations.count] }
    var tapeWidth: CGFloat { tapeWidths[entry.tapeStyle % tapeWidths.count] }

    var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: entry.date)
    }

    var weekdayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: entry.date)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Card background (paper)
            VStack(alignment: .leading, spacing: 12) {
                Spacer().frame(height: 8)  // space for tape overlap

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(weekdayString)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appTextSecondary)
                        Text(dateString)
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary.opacity(0.7))
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Text(entry.moodEmoji)
                            .font(.subheadline)
                        if entry.isStarred {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(Color.appGold)
                        }
                    }
                }

                Text(entry.content)
                    .font(.body)
                    .foregroundStyle(Color(red: 0.12, green: 0.22, blue: 0.16))
                    .lineSpacing(5)
                    .lineLimit(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.10), radius: 4, x: 1, y: 3)
                    .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 8)
            )

            // Tape decoration
            tapeColors[entry.tapeStyle % tapeColors.count]
                .opacity(0.85)
                .frame(width: tapeWidth, height: 18)
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .rotationEffect(.degrees(tapeRotation))
                .offset(x: 24, y: -8)
        }
        .padding(.top, 10)
    }
}

// MARK: - New Entry Sheet
struct NewJournalEntrySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var content = ""
    @State private var mood = 3
    @State private var tapeStyle = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                paperColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Paper writing area
                            ZStack(alignment: .topLeading) {
                                // Tape preview
                                tapeColors[tapeStyle]
                                    .opacity(0.85)
                                    .frame(width: tapeWidths[tapeStyle], height: 18)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                    .rotationEffect(.degrees(tapeRotations[tapeStyle]))
                                    .offset(x: 28, y: -9)
                                    .zIndex(1)

                                VStack(alignment: .leading, spacing: 12) {
                                    Spacer().frame(height: 6)

                                    Text(Date(), format: .dateTime.weekday(.wide).month().day())
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)

                                    ZStack(alignment: .topLeading) {
                                        if content.isEmpty {
                                            Text("What's on your mind today?")
                                                .font(.body)
                                                .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                                                .padding(.top, 2)
                                        }
                                        TextEditor(text: $content)
                                            .font(.body)
                                            .foregroundStyle(Color(red: 0.12, green: 0.22, blue: 0.16))
                                            .scrollContentBackground(.hidden)
                                            .background(.clear)
                                            .frame(minHeight: 200)
                                            .focused($isFocused)
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.10), radius: 4, x: 1, y: 3)
                                )
                            }
                            .padding(.top, 12)

                            // Mood selector
                            VStack(alignment: .leading, spacing: 10) {
                                Text("How are you feeling?")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appPlum)
                                HStack(spacing: 12) {
                                    ForEach(1...5, id: \.self) { level in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) { mood = level }
                                        } label: {
                                            Text(moodEmoji(level))
                                                .font(mood == level ? .title : .title3)
                                                .scaleEffect(mood == level ? 1.2 : 1.0)
                                                .padding(10)
                                                .background(mood == level ? Color.appPlum.opacity(0.1) : Color.clear)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                            }

                            // Tape style picker
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Pick your tape")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.appPlum)
                                HStack(spacing: 10) {
                                    ForEach(0..<tapeColors.count, id: \.self) { i in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) { tapeStyle = i }
                                        } label: {
                                            tapeColors[i]
                                                .opacity(0.85)
                                                .frame(width: 44, height: 22)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                                .rotationEffect(.degrees(tapeStyle == i ? 0 : tapeRotations[i]))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(tapeStyle == i ? Color.appPlum : Color.clear, lineWidth: 2)
                                                )
                                                .scaleEffect(tapeStyle == i ? 1.1 : 1.0)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("New Entry")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(content.trimmingCharacters(in: .whitespaces).isEmpty ? Color.appTextSecondary : Color.appPlum)
                    .disabled(content.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { isFocused = true }
        }
    }

    private func moodEmoji(_ level: Int) -> String {
        switch level {
        case 1: return "😔"
        case 2: return "😐"
        case 3: return "🙂"
        case 4: return "😊"
        case 5: return "🔥"
        default: return "🙂"
        }
    }

    private func saveEntry() {
        let entry = JournalEntry(
            content: content.trimmingCharacters(in: .whitespaces),
            mood: mood,
            tapeStyle: tapeStyle
        )
        modelContext.insert(entry)
    }
}

// MARK: - Empty State
struct JournalEmptyState: View {
    @Binding var showNewEntry: Bool
    let showStarredOnly: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("📝")
                .font(.system(size: 64))

            VStack(spacing: 8) {
                Text(showStarredOnly ? "No starred entries yet" : "Your journal is empty")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appPlum)
                Text(showStarredOnly
                     ? "Star your favourite entries to find them here."
                     : "Write about your day, your goals, how you're feeling. This is your space.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if !showStarredOnly {
                Button {
                    showNewEntry = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text("Write your first entry").fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appPlum)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
            }
        }
        .padding()
    }
}
