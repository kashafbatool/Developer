//
//  MessageInboxView.swift
//  Wombitious
//

import SwiftUI
import SwiftData

// MARK: - Future Notes Inbox

struct MessageInboxView: View {
    @Query(sort: \Message.createdDate, order: .reverse) private var notes: [Message]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedNote: Message?
    @State private var showCompose = false

    var readyToRead: [Message]  { notes.filter {  $0.isUnlocked && !$0.isRead } }
    var alreadyRead: [Message]  { notes.filter {  $0.isUnlocked &&  $0.isRead } }
    var locked: [Message]       { notes.filter { !$0.isUnlocked } }

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color.appBackground.ignoresSafeArea()

                    if notes.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 20) {

                                if !readyToRead.isEmpty {
                                    sectionLabel("Ready to Read ✨")
                                    ForEach(readyToRead) { note in
                                        NoteCard(note: note) {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                                selectedNote = note
                                            }
                                        }
                                    }
                                }

                                if !locked.isEmpty {
                                    sectionLabel("Sealed 🔒")
                                    ForEach(locked) { note in
                                        LockedNoteCard(note: note)
                                    }
                                }

                                if !alreadyRead.isEmpty {
                                    sectionLabel("Read")
                                    ForEach(alreadyRead) { note in
                                        NoteCard(note: note) {
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                                selectedNote = note
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .navigationTitle("Future Notes 💌")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                            .foregroundStyle(Color.appPlum)
                    }
                    ToolbarItem(placement: .automatic) {
                        Button { showCompose = true } label: {
                            Image(systemName: "square.and.pencil")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appPlum)
                                .padding(8)
                                .background(Color.appPlum.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Write a note to future self")
                    }
                }
                .sheet(isPresented: $showCompose) {
                    ComposeNoteSheet()
                }
            }

            // Letter overlay sits above NavigationStack
            if let note = selectedNote {
                LetterOverlay(message: note) {
                    withAnimation(.easeIn(duration: 0.18)) { selectedNote = nil }
                }
                .transition(.opacity)
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.appTextSecondary)
            .tracking(1.2)
    }

    private var emptyState: some View {
        VStack(spacing: 22) {
            Text("💌")
                .font(.system(size: 64))
            VStack(spacing: 8) {
                Text("No letters yet")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appPlum)
                Text("Write a note to your future self — to be opened in a week, a month, or a year.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Button { showCompose = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                    Text("Write your first letter").fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.appPlum)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Unlocked Note Card

struct NoteCard: View {
    let note: Message
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(note.isRead ? Color.appGold.opacity(0.10) : Color.appPlum.opacity(0.10))
                        .frame(width: 46, height: 46)
                    Text(note.isRead ? "✉️" : "💌")
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(note.isRead ? "Past You" : "Ready to read!")
                            .font(.subheadline.bold())
                            .foregroundStyle(note.isRead ? Color.appTextSecondary : Color.appPlum)
                        Spacer()
                        Text(note.createdDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .lineSpacing(2)
                }

                if !note.isRead {
                    Circle()
                        .fill(Color.appGold)
                        .frame(width: 9, height: 9)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: note.isRead ? .black.opacity(0.03) : Color.appGold.opacity(0.18),
                radius: 8, y: 3
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(note.isRead ? Color.clear : Color.appGold.opacity(0.35), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Locked Note Card

struct LockedNoteCard: View {
    let note: Message

    var daysUntil: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: note.unlockDate).day ?? 0)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appTextSecondary.opacity(0.08))
                    .frame(width: 46, height: 46)
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.45))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(note.deliveryLabel) note")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.appTextSecondary)
                    Spacer()
                    Text(note.createdDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary.opacity(0.6))
                }
                Text("Opens \(note.unlockDate.formatted(date: .abbreviated, time: .omitted)) · \(daysUntil) day\(daysUntil == 1 ? "" : "s") to go")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.02), radius: 4, y: 2)
    }
}

// MARK: - Letter Overlay

struct LetterOverlay: View {
    let message: Message
    let onDismiss: () -> Void

    @State private var appeared = false

    var daysAgo: Int {
        max(0, Calendar.current.dateComponents([.day], from: message.createdDate, to: Date()).day ?? 0)
    }

    var timeAgoLabel: String {
        switch daysAgo {
        case 0:  return "today"
        case 1:  return "yesterday"
        default: return "\(daysAgo) days ago"
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(appeared ? 0.45 : 0)
                .ignoresSafeArea()
                .onTapGesture { close() }
                .animation(.easeOut(duration: 0.25), value: appeared)

            VStack(spacing: 0) {
                Text("💌")
                    .font(.system(size: 52))
                    .scaleEffect(appeared ? 1.0 : 0.2)
                    .animation(.spring(response: 0.45, dampingFraction: 0.58).delay(0.12), value: appeared)
                    .padding(.bottom, 14)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FROM")
                            .font(.caption2).fontWeight(.semibold).tracking(2.5)
                            .foregroundStyle(Color.appGold)
                        Text("Past You 🌟")
                            .font(.title2.bold())
                            .foregroundStyle(Color.appPlum)
                    }

                    HStack(spacing: 6) {
                        Rectangle().fill(Color.appGold.opacity(0.5)).frame(height: 1)
                        Text("✨").font(.caption2)
                        Rectangle().fill(Color.appGold.opacity(0.5)).frame(height: 1)
                    }

                    Text(message.content)
                        .font(.body)
                        .foregroundStyle(Color(red: 0.18, green: 0.08, blue: 0.24))
                        .lineSpacing(7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Text("Written \(timeAgoLabel)")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        Button("Close") { close() }
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.appPlum)
                    }
                }
                .padding(28)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.98, blue: 0.94),
                            Color(red: 0.98, green: 0.95, blue: 0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.appGold.opacity(0.3), lineWidth: 1))
                .shadow(color: .black.opacity(0.22), radius: 28, y: 10)
            }
            .padding(.horizontal, 28)
            .offset(y: appeared ? 0 : 50)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.78), value: appeared)
        }
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                message.isRead = true
            }
        }
    }

    private func close() {
        withAnimation(.easeIn(duration: 0.18)) { appeared = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { onDismiss() }
    }
}

// MARK: - Compose Note Sheet

struct ComposeNoteSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDelivery = 1  // 0=week, 1=month, 2=year
    @State private var content = ""
    @State private var sent = false
    @FocusState private var isFocused: Bool

    private let deliveryOptions: [(label: String, days: Int)] = [
        ("1 Week", 7),
        ("1 Month", 30),
        ("1 Year", 365)
    ]

    private var unlockDate: Date {
        Calendar.current.date(byAdding: .day, value: deliveryOptions[selectedDelivery].days, to: Date()) ?? Date()
    }

    private var canSend: Bool {
        content.trimmingCharacters(in: .whitespaces).count >= 5
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if sent {
                    sentConfirmation
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    composeForm
                }
            }
            .navigationTitle("Write to Future You 💌")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                        .opacity(sent ? 0 : 1)
                }
            }
            .onAppear { isFocused = true }
        }
    }

    private var composeForm: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // Delivery picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("WHEN SHOULD IT OPEN?")
                        .font(.caption2).fontWeight(.semibold).tracking(1.5)
                        .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: 10) {
                        ForEach(0..<deliveryOptions.count, id: \.self) { i in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedDelivery = i }
                            } label: {
                                Text(deliveryOptions[i].label)
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundStyle(selectedDelivery == i ? .white : Color.appPlum)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(selectedDelivery == i ? Color.appPlum : Color.appPlum.opacity(0.08))
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer()
                    }

                    Text("Opens \(unlockDate.formatted(date: .long, time: .omitted))")
                        .font(.caption).fontWeight(.medium)
                        .foregroundStyle(Color.appGold)
                }

                // Live preview
                letterPreview

                // Message editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("YOUR MESSAGE")
                        .font(.caption2).fontWeight(.semibold).tracking(1.5)
                        .foregroundStyle(Color.appTextSecondary)

                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("What do you want your future self to know?")
                                .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                                .font(.body)
                                .padding(.top, 12)
                                .padding(.leading, 16)
                        }
                        TextEditor(text: $content)
                            .foregroundStyle(Color(red: 0.18, green: 0.08, blue: 0.24))
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 130)
                            .focused($isFocused)
                            .padding(10)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                }

                Button {
                    saveNote()
                } label: {
                    Text("Seal & Send 💌")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSend ? Color.appPlum : Color.appTextSecondary.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!canSend)
            }
            .padding(20)
        }
    }

    @ViewBuilder
    private var letterPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💌").font(.largeTitle)
                Spacer()
                Text("Opens \(unlockDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).fontWeight(.medium)
                    .foregroundStyle(Color.appGold)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("TO")
                    .font(.caption2).fontWeight(.semibold).tracking(2.5)
                    .foregroundStyle(Color.appGold)
                Text("Future You 🌟")
                    .font(.headline).foregroundStyle(Color.appPlum)
            }

            HStack(spacing: 6) {
                Rectangle().fill(Color.appGold.opacity(0.4)).frame(height: 1)
                Text("✨").font(.caption2)
                Rectangle().fill(Color.appGold.opacity(0.4)).frame(height: 1)
            }

            Text(content.isEmpty ? "Your words will appear here…" : content)
                .font(.body)
                .foregroundStyle(
                    content.isEmpty
                        ? Color.appTextSecondary.opacity(0.45)
                        : Color(red: 0.18, green: 0.08, blue: 0.24)
                )
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 60)

            Text("— Past You, \(Date().formatted(date: .abbreviated, time: .omitted))")
                .font(.subheadline.italic())
                .foregroundStyle(Color.appGold)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(red: 1.00, green: 0.98, blue: 0.94), Color(red: 0.98, green: 0.95, blue: 0.90)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appGold.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.appPlum.opacity(0.08), radius: 16, y: 4)
    }

    private var sentConfirmation: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("💌")
                .font(.system(size: 80))
            VStack(spacing: 8) {
                Text("Letter sealed!")
                    .font(.title.bold())
                    .foregroundStyle(Color.appPlum)
                Text("It'll be waiting for you on\n\(unlockDate.formatted(date: .long, time: .omitted)).")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                dismiss()
            } label: {
                Text("Done 💛")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appPlum)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            Spacer()
        }
    }

    private func saveNote() {
        let option = deliveryOptions[selectedDelivery]
        let msg = Message(
            content: content.trimmingCharacters(in: .whitespaces),
            unlockDate: unlockDate,
            deliveryLabel: option.label
        )
        modelContext.insert(msg)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { sent = true }
    }
}

#Preview {
    MessageInboxView()
        .modelContainer(for: [Message.self])
}
