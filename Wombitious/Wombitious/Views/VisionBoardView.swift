//
//  VisionBoardView.swift
//  Wombitious
//

import SwiftUI
import SwiftData
import PhotosUI

private let quoteBackgrounds: [Color] = [
    Color.appPlum,
    Color(red: 0.17, green: 0.43, blue: 0.29),
    Color(red: 0.11, green: 0.28, blue: 0.19),
    Color.appCoral,
    Color(red: 0.22, green: 0.50, blue: 0.35),
]

// MARK: - Main View

struct VisionBoardView: View {
    @Query(sort: \VisionItem.createdDate, order: .forward) private var items: [VisionItem]
    @Environment(\.modelContext) private var modelContext

    @State private var isZoomed      = false
    @State private var galleryVisible = false
    @State private var showAddSheet  = false
    @State private var zoomTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            // ── Bedroom scene — scales toward wall on zoom ──
            BedroomScene(isZoomed: isZoomed)
                .ignoresSafeArea()

            // ── Interactive gallery — fades in after zoom settles ──
            if galleryVisible {
                WallGallery(
                    items: items,
                    onBack: zoomOut,
                    onAdd: { showAddSheet = true },
                    onDelete: { modelContext.delete($0) }
                )
                .transition(.opacity)
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // Each time the tab becomes visible, play the cinematic zoom
            // (guard prevents double-fire if already zoomed in)
            guard !isZoomed else { return }
            zoomTask?.cancel()
            zoomTask = Task {
                // Brief pause — user glimpses the room first
                try? await Task.sleep(for: .seconds(0.4))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 1.2)) { isZoomed = true }
                }
            }
        }
        .onChange(of: isZoomed) { _, zoomed in
            guard zoomed else { return }
            // Wait for zoom to settle, then reveal the gallery overlay
            zoomTask = Task {
                try? await Task.sleep(for: .seconds(1.05))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.35)) { galleryVisible = true }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddVisionItemSheet()
        }
    }

    // MARK: Zoom-out sequence

    private func zoomOut() {
        zoomTask?.cancel()
        withAnimation(.easeOut(duration: 0.22)) { galleryVisible = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeInOut(duration: 0.95)) { isZoomed = false }
        }
        // onAppear will re-trigger the zoom next time the user returns to this tab
    }
}

// MARK: - Bedroom Scene

struct BedroomScene: View {
    let isZoomed: Bool

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                roomContent(w: w, h: h)
            }
            .scaleEffect(isZoomed ? 2.6 : 1.0, anchor: UnitPoint(x: 0.5, y: 0.26))
            .animation(.easeInOut(duration: 1.2), value: isZoomed)
        }
    }

    // MARK: Room composition

    @ViewBuilder
    private func roomContent(w: CGFloat, h: CGFloat) -> some View {
        // ── Wall ──────────────────────────────────────────────────
        LinearGradient(
            colors: [
                Color(red: 0.87, green: 0.82, blue: 0.73),
                Color(red: 0.80, green: 0.74, blue: 0.64)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .frame(width: w, height: h * 0.65)
        .position(x: w / 2, y: h * 0.325)

        // ── Floor ─────────────────────────────────────────────────
        LinearGradient(
            colors: [
                Color(red: 0.63, green: 0.48, blue: 0.35),
                Color(red: 0.50, green: 0.36, blue: 0.24)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .frame(width: w, height: h * 0.40)
        .position(x: w / 2, y: h * 0.80)

        // Baseboard
        Rectangle()
            .fill(Color(red: 0.92, green: 0.86, blue: 0.77))
            .frame(width: w, height: 7)
            .position(x: w / 2, y: h * 0.638)

        // Floor planks
        ForEach(0..<7, id: \.self) { i in
            Rectangle()
                .fill(Color.black.opacity(0.035))
                .frame(width: w, height: 1.5)
                .position(x: w / 2, y: h * 0.648 + CGFloat(i) * 15)
        }

        // ── Warm lamp glows on wall ───────────────────────────────
        radialGlow(w: w, cx: w * 0.16, cy: h * 0.52, radius: w * 0.24)
        radialGlow(w: w, cx: w * 0.84, cy: h * 0.52, radius: w * 0.24)

        // ── Decorative wall frames (room-view hints) ──────────────
        decorativeFrame(
            x: w * 0.33, y: h * 0.22, fw: w * 0.14, fh: h * 0.10,
            fill: Color.appPlum.opacity(0.88)
        )
        decorativeFrame(
            x: w * 0.52, y: h * 0.175, fw: w * 0.12, fh: h * 0.13,
            fill: Color(red: 0.55, green: 0.35, blue: 0.70).opacity(0.85)
        )
        decorativeFrame(
            x: w * 0.695, y: h * 0.235, fw: w * 0.14, fh: h * 0.09,
            fill: Color.appCoral.opacity(0.82)
        )

        // ── Headboard ─────────────────────────────────────────────
        RoundedRectangle(cornerRadius: 10)
            .fill(LinearGradient(
                colors: [Color(red: 0.36, green: 0.22, blue: 0.12),
                         Color(red: 0.26, green: 0.15, blue: 0.07)],
                startPoint: .top, endPoint: .bottom
            ))
            .frame(width: w * 0.65, height: h * 0.155)
            .position(x: w / 2, y: h * 0.620)

        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(Color(red: 0.55, green: 0.38, blue: 0.20).opacity(0.45), lineWidth: 2)
            .frame(width: w * 0.56, height: h * 0.10)
            .position(x: w / 2, y: h * 0.620)

        // ── Duvet ─────────────────────────────────────────────────
        RoundedRectangle(cornerRadius: 12)
            .fill(LinearGradient(
                colors: [Color(red: 0.28, green: 0.12, blue: 0.40),
                         Color(red: 0.20, green: 0.08, blue: 0.30)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
            .frame(width: w * 0.68, height: h * 0.175)
            .position(x: w / 2, y: h * 0.748)

        // Duvet fold
        RoundedRectangle(cornerRadius: 5)
            .fill(Color(red: 0.38, green: 0.18, blue: 0.54).opacity(0.72))
            .frame(width: w * 0.68, height: h * 0.03)
            .position(x: w / 2, y: h * 0.661)

        // ── Pillows ───────────────────────────────────────────────
        pillow(w: w, h: h, cx: 0.39, cy: 0.647, angle: -2.5)
        pillow(w: w, h: h, cx: 0.61, cy: 0.647, angle:  2.5)

        // ── Nightstands ───────────────────────────────────────────
        nightstand(w: w, h: h, cx: 0.155, cy: 0.700)
        nightstand(w: w, h: h, cx: 0.845, cy: 0.700)

        // ── Potted plant ──────────────────────────────────────────
        plant(w: w, h: h, cx: 0.055, cy: 0.700)
    }

    // MARK: Shape helpers

    private func radialGlow(w: CGFloat, cx: CGFloat, cy: CGFloat, radius: CGFloat) -> some View {
        RadialGradient(
            colors: [Color(red: 1.0, green: 0.92, blue: 0.65).opacity(0.45), .clear],
            center: .center, startRadius: 4, endRadius: radius
        )
        .frame(width: radius * 2, height: radius * 2)
        .position(x: cx, y: cy)
        .blendMode(.screen)
    }

    @ViewBuilder
    private func decorativeFrame(x: CGFloat, y: CGFloat, fw: CGFloat, fh: CGFloat, fill: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.36, green: 0.24, blue: 0.12))
                .frame(width: fw + 8, height: fh + 8)
            RoundedRectangle(cornerRadius: 1)
                .fill(fill)
                .frame(width: fw, height: fh)
        }
        .shadow(color: .black.opacity(0.35), radius: 5, x: 1, y: 3)
        .position(x: x, y: y)
    }

    @ViewBuilder
    private func pillow(w: CGFloat, h: CGFloat, cx: CGFloat, cy: CGFloat, angle: Double) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 0.97, green: 0.93, blue: 0.87))
            .frame(width: w * 0.22, height: h * 0.074)
            .rotationEffect(.degrees(angle))
            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
            .position(x: w * cx, y: h * cy)
    }

    @ViewBuilder
    private func nightstand(w: CGFloat, h: CGFloat, cx: CGFloat, cy: CGFloat) -> some View {
        // Table body
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red: 0.40, green: 0.26, blue: 0.14))
            .frame(width: w * 0.11, height: h * 0.06)
            .position(x: w * cx, y: h * cy + h * 0.025)

        // Lamp pole
        Rectangle()
            .fill(Color(red: 0.64, green: 0.46, blue: 0.26))
            .frame(width: 3, height: h * 0.065)
            .position(x: w * cx, y: h * cy - h * 0.005)

        // Lamp shade
        Ellipse()
            .fill(Color(red: 0.97, green: 0.88, blue: 0.68))
            .frame(width: w * 0.09, height: h * 0.024)
            .position(x: w * cx, y: h * cy - h * 0.042)
    }

    @ViewBuilder
    private func plant(w: CGFloat, h: CGFloat, cx: CGFloat, cy: CGFloat) -> some View {
        // Pot
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(red: 0.70, green: 0.50, blue: 0.36))
            .frame(width: w * 0.065, height: h * 0.046)
            .position(x: w * cx, y: h * cy + h * 0.025)

        // Leaves
        Ellipse()
            .fill(Color(red: 0.22, green: 0.47, blue: 0.27))
            .frame(width: w * 0.042, height: h * 0.055)
            .rotationEffect(.degrees(-22))
            .position(x: w * cx - w * 0.018, y: h * cy - h * 0.018)

        Ellipse()
            .fill(Color(red: 0.28, green: 0.54, blue: 0.32))
            .frame(width: w * 0.048, height: h * 0.065)
            .rotationEffect(.degrees(8))
            .position(x: w * cx + w * 0.008, y: h * cy - h * 0.040)

        Ellipse()
            .fill(Color(red: 0.20, green: 0.43, blue: 0.25))
            .frame(width: w * 0.038, height: h * 0.048)
            .rotationEffect(.degrees(32))
            .position(x: w * cx + w * 0.022, y: h * cy - h * 0.010)
    }
}

// MARK: - Wall Gallery

struct WallGallery: View {
    let items: [VisionItem]
    let onBack: () -> Void
    let onAdd: () -> Void
    let onDelete: (VisionItem) -> Void

    var body: some View {
        ZStack {
            // Frosted wall material over the zoomed-in background
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .light)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                if items.isEmpty {
                    emptyState
                } else {
                    framesGrid
                }
            }
        }
    }

    // MARK: Nav bar

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                    .foregroundColor(Color.appPlum)
                    .padding(10)
                    .background(Color.white.opacity(0.82))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            }

            Spacer()

            Text("Vision Board")
                .font(.headline)
                .foregroundColor(Color.appPlum)

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        LinearGradient(
                            colors: [Color.appGold, Color.appCoral],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.appGold.opacity(0.4), radius: 6, x: 0, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }

    // MARK: Frames grid

    private var framesGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                spacing: 14
            ) {
                ForEach(items) { item in
                    WallFrame(item: item)
                        .contextMenu {
                            Button(role: .destructive) { onDelete(item) } label: {
                                Label("Remove from wall", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: 22) {
            Spacer()

            // Empty frame prop
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.38, green: 0.26, blue: 0.14))
                    .frame(width: 148, height: 116)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.97, green: 0.93, blue: 0.87))
                    .frame(width: 126, height: 94)
                Image(systemName: "photo.on.rectangle")
                    .font(.title)
                    .foregroundColor(Color.appTextSecondary.opacity(0.5))
            }
            .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 6)

            VStack(spacing: 6) {
                Text("Your wall is empty")
                    .font(.title3.bold())
                    .foregroundColor(Color.appPlum)
                Text("Add photos and quotes that inspire you.")
                    .font(.subheadline)
                    .foregroundColor(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add to your wall").fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.appPlum, Color(red: 0.38, green: 0.18, blue: 0.55)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 48)

            Spacer()
        }
    }
}

// MARK: - Wall Frame

struct WallFrame: View {
    let item: VisionItem

    private var bgColor: Color {
        quoteBackgrounds[item.colorIndex % quoteBackgrounds.count]
    }

    var body: some View {
        frameContent
            .padding(5)
            .background(Color(red: 0.97, green: 0.93, blue: 0.87))   // cream mat
            .padding(7)
            .background(Color(red: 0.36, green: 0.24, blue: 0.12))   // wood frame
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: .black.opacity(0.32), radius: 10, x: 2, y: 6)
            .rotationEffect(.degrees(item.rotation * 0.45))
    }

    @ViewBuilder
    private var frameContent: some View {
        if item.type == .image,
           let data = item.imageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 130)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 2))
        } else {
            ZStack {
                bgColor
                VStack(spacing: 6) {
                    Text("\"")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                    Text(item.content)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 12)
                }
            }
            .frame(height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }
}

// MARK: - Add Vision Item Sheet

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
            .navigationTitle("Add to Wall")
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
            // Frame preview
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
            .padding(5)
            .background(Color(red: 0.97, green: 0.93, blue: 0.87))
            .padding(7)
            .background(Color(red: 0.36, green: 0.24, blue: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 1, y: 4)

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
                    .padding(5)
                    .background(Color(red: 0.97, green: 0.93, blue: 0.87))
                    .padding(7)
                    .background(Color(red: 0.36, green: 0.24, blue: 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 1, y: 4)
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
            item = VisionItem(
                type: .quote,
                content: quoteText.trimmingCharacters(in: .whitespaces),
                colorIndex: colorIndex
            )
        } else {
            let data = pickedImage?.jpegData(compressionQuality: 0.75)
            item = VisionItem(type: .image, imageData: data)
        }
        modelContext.insert(item)
    }
}

#Preview {
    VisionBoardView()
        .modelContainer(for: [VisionItem.self])
}
