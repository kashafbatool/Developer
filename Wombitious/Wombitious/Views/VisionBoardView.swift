//
//  VisionBoardView.swift
//  Wombitious
//
//  Created by Kashaf Batool
//

import SwiftUI
import SwiftData
import PhotosUI

private let quoteBackgrounds: [Color] = [
    Color.appPlum,                               // #2C6E49 deep green
    Color(red: 0.17, green: 0.43, blue: 0.29),  // dark forest green
    Color(red: 0.11, green: 0.28, blue: 0.19),  // very dark green
    Color.appCoral,                              // #4C956C secondary green
    Color(red: 0.22, green: 0.50, blue: 0.35),  // mid green
]

struct VisionBoardView: View {
    @Query(sort: \VisionItem.createdDate, order: .forward) private var items: [VisionItem]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddSheet = false

    var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.20, blue: 0.12).ignoresSafeArea()

                if items.isEmpty {
                    VisionBoardEmptyState(showAdd: $showAddSheet)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(items) { item in
                                VisionItemCard(item: item)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            modelContext.delete(item)
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Vision Board")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Add photo or quote to vision board")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddVisionItemSheet()
            }
        }
    }
}

// MARK: - Vision Item Card
struct VisionItemCard: View {
    let item: VisionItem

    var bgColor: Color { quoteBackgrounds[item.colorIndex % quoteBackgrounds.count] }

    var body: some View {
        Group {
            if item.type == .image, let data = item.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(minHeight: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ZStack {
                    bgColor
                    VStack(spacing: 10) {
                        Text("\"")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.top, 8)
                        Text(item.content)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 16)
                    }
                }
                .frame(minHeight: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .rotationEffect(.degrees(item.rotation))
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .accessibilityLabel(item.type == .quote ? "Quote: \(item.content)" : "Vision board photo")
    }
}

// MARK: - Add Sheet
struct AddVisionItemSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var mode: VisionItemType = .quote
    @State private var quoteText = ""
    @State private var colorIndex = 0
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pickedImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.20, blue: 0.12).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Mode picker
                        HStack(spacing: 0) {
                            modeButton(label: "Quote", type: .quote, icon: "quote.bubble")
                            modeButton(label: "Photo", type: .image, icon: "photo.fill")
                        }
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        if mode == .quote {
                            quoteEditor
                        } else {
                            photoEditor
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add to Board")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveItem()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canSave ? Color.appGold : .white.opacity(0.3))
                    .disabled(!canSave)
                }
            }
        }
    }

    var canSave: Bool {
        mode == .quote ? !quoteText.trimmingCharacters(in: .whitespaces).isEmpty : pickedImage != nil
    }

    @ViewBuilder
    private var quoteEditor: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Preview card
            ZStack {
                quoteBackgrounds[colorIndex]
                VStack(spacing: 10) {
                    Text("\"")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.top, 8)
                    Text(quoteText.isEmpty ? "Your quote here..." : quoteText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(quoteText.isEmpty ? .white.opacity(0.35) : .white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Text input
            ZStack(alignment: .topLeading) {
                if quoteText.isEmpty {
                    Text("Type a quote, affirmation, or intention...")
                        .foregroundStyle(.white.opacity(0.35))
                        .font(.body)
                        .padding(.top, 10)
                        .padding(.leading, 6)
                }
                TextEditor(text: $quoteText)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 80)
            }
            .padding(12)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Color picker
            Text("Card color")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 10) {
                ForEach(0..<quoteBackgrounds.count, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3)) { colorIndex = i }
                    } label: {
                        Circle()
                            .fill(quoteBackgrounds[i])
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(colorIndex == i ? Color.appGold : Color.clear, lineWidth: 2)
                            )
                            .scaleEffect(colorIndex == i ? 1.15 : 1.0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var photoEditor: some View {
        VStack(spacing: 16) {
            if let img = pickedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.fill")
                    Text(pickedImage == nil ? "Choose Photo" : "Change Photo")
                        .fontWeight(.medium)
                }
                .foregroundStyle(Color.appGold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let ui = UIImage(data: data) {
                        pickedImage = ui
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func modeButton(label: String, type: VisionItemType, icon: String) -> some View {
        Button {
            withAnimation { mode = type }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label).fontWeight(.medium)
            }
            .foregroundStyle(mode == type ? Color.appPlum : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(mode == type ? Color.white : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(4)
        }
    }

    private func saveItem() {
        let item: VisionItem
        if mode == .quote {
            item = VisionItem(type: .quote, content: quoteText.trimmingCharacters(in: .whitespaces), colorIndex: colorIndex)
        } else {
            let data = pickedImage?.jpegData(compressionQuality: 0.75)
            item = VisionItem(type: .image, imageData: data)
        }
        modelContext.insert(item)
    }
}

// MARK: - Empty State
struct VisionBoardEmptyState: View {
    @Binding var showAdd: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("🌟")
                .font(.system(size: 64))
            VStack(spacing: 8) {
                Text("Your Vision Board")
                    .font(.title2).fontWeight(.bold).foregroundStyle(.white)
                Text("Add photos and quotes that inspire you. See your dreams every day.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Button {
                showAdd = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add your first item").fontWeight(.semibold)
                }
                .foregroundStyle(Color.appPlum)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
