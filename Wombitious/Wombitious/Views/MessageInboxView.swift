//
//  MessageInboxView.swift
//  Wombitious
//

import SwiftUI
import SwiftData

// MARK: - Inbox

struct MessageInboxView: View {
    @Query(sort: \Message.createdDate, order: .reverse) private var messages: [Message]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMessage: Message?
    @State private var showCompose = false

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color.appBackground.ignoresSafeArea()

                    if messages.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(messages) { message in
                                    MessageCard(message: message) {
                                        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                                            selectedMessage = message
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .navigationTitle("Messages 💌")
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
                        .accessibilityLabel("Leave a note")
                    }
                }
                .sheet(isPresented: $showCompose) {
                    ComposeMessageSheet()
                }
            }

            // Letter overlay — sits above NavigationStack inside the same ZStack
            if let message = selectedMessage {
                LetterOverlay(message: message) {
                    withAnimation(.easeIn(duration: 0.18)) { selectedMessage = nil }
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: 22) {
            Text("💌")
                .font(.system(size: 64))

            VStack(spacing: 8) {
                Text("No messages yet")
                    .font(.title3.bold())
                    .foregroundStyle(Color.appPlum)
                Text("Ask a friend or family member to leave you a note here.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button { showCompose = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                    Text("Leave the first note").fontWeight(.semibold)
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

// MARK: - Message Card (list row)

struct MessageCard: View {
    let message: Message
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Avatar circle
                ZStack {
                    Circle()
                        .fill(message.isRead
                              ? Color.appGold.opacity(0.10)
                              : Color.appPlum.opacity(0.10))
                        .frame(width: 46, height: 46)
                    Text(message.isRead ? "✉️" : "💌")
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(message.senderName)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.appPlum)
                        Spacer()
                        Text(message.createdDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Text(message.content)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .lineSpacing(2)
                }

                // Unread dot
                if !message.isRead {
                    Circle()
                        .fill(Color.appGold)
                        .frame(width: 9, height: 9)
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: message.isRead ? .black.opacity(0.03) : Color.appGold.opacity(0.18),
                radius: 8, y: 3
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(message.isRead ? Color.clear : Color.appGold.opacity(0.35), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Letter Overlay

struct LetterOverlay: View {
    let message: Message
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Dim backdrop
            Color.black
                .opacity(appeared ? 0.45 : 0)
                .ignoresSafeArea()
                .onTapGesture { close() }
                .animation(.easeOut(duration: 0.25), value: appeared)

            VStack(spacing: 0) {
                // Floating envelope pop
                Text("💌")
                    .font(.system(size: 52))
                    .scaleEffect(appeared ? 1.0 : 0.2)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.58).delay(0.12),
                        value: appeared
                    )
                    .padding(.bottom, 14)

                // Letter card
                VStack(alignment: .leading, spacing: 20) {
                    // From header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FROM")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .tracking(2.5)
                            .foregroundStyle(Color.appGold)
                        Text(message.senderName)
                            .font(.title2.bold())
                            .foregroundStyle(Color.appPlum)
                    }

                    // Decorative divider
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(Color.appGold.opacity(0.5))
                            .frame(height: 1)
                        Text("✨")
                            .font(.caption2)
                        Rectangle()
                            .fill(Color.appGold.opacity(0.5))
                            .frame(height: 1)
                    }

                    // Message body
                    Text(message.content)
                        .font(.body)
                        .foregroundStyle(Color(red: 0.18, green: 0.08, blue: 0.24))
                        .lineSpacing(7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // Footer
                    HStack {
                        Text(message.createdDate.formatted(date: .long, time: .omitted))
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
                    // Warm paper feel
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
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.appGold.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.22), radius: 28, y: 10)
            }
            .padding(.horizontal, 28)
            .offset(y: appeared ? 0 : 50)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.78), value: appeared)
        }
        .onAppear {
            appeared = true
            // Mark as read after letter is fully visible
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

// MARK: - Compose Sheet

struct ComposeMessageSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var senderName = ""
    @State private var messageContent = ""
    @State private var sent = false

    var canSend: Bool {
        !senderName.trimmingCharacters(in: .whitespaces).isEmpty
            && messageContent.trimmingCharacters(in: .whitespaces).count >= 5
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
            .navigationTitle("Leave a Note 💌")
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
        }
    }

    // MARK: Compose form

    private var composeForm: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Live preview card
                letterPreview

                // Fields
                VStack(spacing: 18) {
                    labeledField(label: "Your name") {
                        TextField("e.g. Mum, Best Friend, Aisha…", text: $senderName)
                            .foregroundStyle(Color.appPlum)
                            .fieldStyle()
                    }

                    labeledField(label: "Your message") {
                        ZStack(alignment: .topLeading) {
                            if messageContent.isEmpty {
                                Text("Write something kind, encouraging, or funny…")
                                    .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                                    .font(.body)
                                    .padding(.top, 10)
                                    .padding(.leading, 6)
                            }
                            TextEditor(text: $messageContent)
                                .foregroundStyle(Color(red: 0.18, green: 0.08, blue: 0.24))
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 110)
                        }
                        .fieldStyle()
                    }

                    Button { sendMessage() } label: {
                        Text("Send with love 💛")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSend ? Color.appPlum : Color.appTextSecondary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!canSend)
                }
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
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("TO")
                    .font(.caption2).fontWeight(.semibold).tracking(2.5)
                    .foregroundStyle(Color.appGold)
                Text("You 🌟")
                    .font(.headline).foregroundStyle(Color.appPlum)
            }

            HStack(spacing: 6) {
                Rectangle().fill(Color.appGold.opacity(0.4)).frame(height: 1)
                Text("✨").font(.caption2)
                Rectangle().fill(Color.appGold.opacity(0.4)).frame(height: 1)
            }

            Text(messageContent.isEmpty ? "Your message will appear here…" : messageContent)
                .font(.body)
                .foregroundStyle(
                    messageContent.isEmpty
                        ? Color.appTextSecondary.opacity(0.45)
                        : Color(red: 0.18, green: 0.08, blue: 0.24)
                )
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 60)

            if !senderName.isEmpty {
                Text("— \(senderName)")
                    .font(.subheadline.italic())
                    .foregroundStyle(Color.appGold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
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

    // MARK: Sent confirmation

    private var sentConfirmation: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("💌")
                .font(.system(size: 80))
            VStack(spacing: 8) {
                Text("Note left!")
                    .font(.title.bold())
                    .foregroundStyle(Color.appPlum)
                Text("They'll see your message the next time\nthey open the app.")
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

    // MARK: Helpers

    @ViewBuilder
    private func labeledField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption2).fontWeight(.semibold).tracking(1.5)
                .foregroundStyle(Color.appTextSecondary)
            content()
        }
    }

    private func sendMessage() {
        let msg = Message(
            senderName: senderName.trimmingCharacters(in: .whitespaces),
            content: messageContent.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(msg)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) { sent = true }
    }
}

// MARK: - Field style helper

private extension View {
    func fieldStyle() -> some View {
        self
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

#Preview {
    MessageInboxView()
        .modelContainer(for: [Message.self])
}
