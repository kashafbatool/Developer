//
//  ProfileEditView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    let userProgress: UserProgress
    @Environment(\.dismiss) private var dismiss

    @State private var username: String
    @State private var selectedEmoji: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoImage: UIImage?

    private let emojiOptions = ["✨", "🌸", "💜", "🔥", "🌙", "⭐️", "🦋", "🌺", "💫", "🎯", "🏆", "💎"]

    init(userProgress: UserProgress) {
        self.userProgress = userProgress
        _username = State(initialValue: userProgress.username)
        _selectedEmoji = State(initialValue: userProgress.avatarEmoji)
        if let data = userProgress.profileImageData {
            _photoImage = State(initialValue: UIImage(data: data))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Preview avatar
                        avatarPreview

                        // Photo picker
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                Text("Choose Photo")
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(Color.appPlum)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appPlum.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .onChange(of: selectedPhoto) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let ui = UIImage(data: data) {
                                    photoImage = ui
                                }
                            }
                        }

                        if photoImage != nil {
                            Button(role: .destructive) {
                                photoImage = nil
                                selectedPhoto = nil
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                    Text("Remove Photo")
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Name")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appPlum)
                            TextField("e.g. Kashaf", text: $username)
                                .font(.body)
                                .padding(14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
                        }

                        // Emoji picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Avatar Emoji")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appPlum)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                                ForEach(emojiOptions, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.title2)
                                            .frame(width: 48, height: 48)
                                            .background(selectedEmoji == emoji ? Color.appPlum.opacity(0.12) : Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedEmoji == emoji ? Color.appPlum : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
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
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPlum)
                }
            }
        }
    }

    private var avatarPreview: some View {
        ZStack {
            Circle()
                .fill(Color.appPlum.opacity(0.12))
                .frame(width: 100, height: 100)
            if let img = photoImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Text(selectedEmoji)
                    .font(.system(size: 46))
            }
        }
        .overlay(
            Circle()
                .stroke(Color.appPlum.opacity(0.2), lineWidth: 2)
        )
    }

    private func saveChanges() {
        userProgress.username = username.trimmingCharacters(in: .whitespaces)
        userProgress.avatarEmoji = selectedEmoji
        if let img = photoImage {
            userProgress.profileImageData = img.jpegData(compressionQuality: 0.7)
        } else {
            userProgress.profileImageData = nil
        }
    }
}
