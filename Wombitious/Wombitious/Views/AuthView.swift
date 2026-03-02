//
//  AuthView.swift
//  Wombitious
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager

    // MARK: - Animation phases
    @State private var backgroundVisible  = false
    @State private var orbsVisible        = false
    @State private var brandVisible       = false
    @State private var formVisible        = false
    @State private var logoCompact        = false

    // MARK: - Orb animation
    @State private var orb1Offset: CGFloat = 0
    @State private var orb2Offset: CGFloat = 0
    @State private var orb3Offset: CGFloat = 0

    // MARK: - Form state
    @State private var isLoginMode   = false
    @State private var email         = ""
    @State private var password      = ""
    @State private var confirmPass   = ""
    @State private var showPassword  = false
    @State private var isLoading     = false
    @State private var errorMessage  = ""

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Background gradient ──
                LinearGradient(
                    colors: [Color.appPlum, Color(red: 0.07, green: 0.04, blue: 0.13)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(backgroundVisible ? 1 : 0)

                // ── Floating orbs ──
                if orbsVisible {
                    orbLayer(geo: geo)
                }

                VStack(spacing: 0) {
                    Spacer()

                    // ── Wordmark / logo ──
                    VStack(spacing: 8) {
                        Image("SheRiseLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: logoCompact ? 220 : 320)

                        if !logoCompact {
                            Text("Your goals. Your story.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .transition(.opacity)
                        }
                    }
                    .scaleEffect(brandVisible ? 1.0 : 0.6)
                    .opacity(brandVisible ? 1 : 0)
                    .padding(.bottom, logoCompact ? 32 : 0)

                    if !logoCompact {
                        Spacer()
                    }

                    // ── Form card ──
                    if formVisible {
                        formCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .onAppear(perform: runEntrance)
        .onChange(of: authManager.hasExistingAccount) { _, hasAccount in
            isLoginMode = hasAccount
        }
        .onAppear {
            isLoginMode = authManager.hasExistingAccount
        }
    }

    // MARK: - Orb layer

    @ViewBuilder
    private func orbLayer(geo: GeometryProxy) -> some View {
        Circle()
            .fill(Color.appPlum.opacity(0.6))
            .frame(width: 260, height: 260)
            .blur(radius: 40)
            .offset(x: -geo.size.width * 0.25, y: -geo.size.height * 0.1 + orb1Offset)

        Circle()
            .fill(Color.appGold.opacity(0.4))
            .frame(width: 200, height: 200)
            .blur(radius: 40)
            .offset(x: geo.size.width * 0.28, y: -geo.size.height * 0.22 + orb2Offset)

        Circle()
            .fill(Color.appCoral.opacity(0.35))
            .frame(width: 180, height: 180)
            .blur(radius: 40)
            .offset(x: geo.size.width * 0.1, y: geo.size.height * 0.1 + orb3Offset)
    }

    // MARK: - Form card

    private var formCard: some View {
        VStack(spacing: 20) {
            // Title
            Text(isLoginMode ? "Welcome back" : "Create your account")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Email
            AuthTextField(
                placeholder: "Email",
                text: $email,
                icon: "envelope"
            )

            // Password
            AuthSecureField(
                placeholder: "Password",
                text: $password,
                showText: $showPassword,
                icon: "lock"
            )

            // Confirm password (sign-up only)
            if !isLoginMode {
                AuthTextField(
                    placeholder: "Confirm password",
                    text: $confirmPass,
                    icon: "lock.fill",
                    isSecure: true
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color(red: 1, green: 0.45, blue: 0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            // CTA button
            Button(action: submit) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.appGold, Color.appCoral],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 52)

                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isLoginMode ? "Sign In" : "Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(isLoading)

            // Toggle link
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoginMode.toggle()
                    errorMessage = ""
                }
            } label: {
                Text(isLoginMode
                     ? "New here? Sign up"
                     : "Already have an account? Log in")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.65))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Actions

    private func submit() {
        errorMessage = ""

        if !isLoginMode && confirmPass != password {
            withAnimation { errorMessage = "Passwords do not match." }
            return
        }

        isLoading = true
        Task {
            do {
                if isLoginMode {
                    try authManager.login(email: email, password: password)
                } else {
                    try authManager.signUp(email: email, password: password)
                }
            } catch {
                await MainActor.run {
                    withAnimation { errorMessage = error.localizedDescription }
                }
            }
            await MainActor.run { isLoading = false }
        }
    }

    // MARK: - Entrance animation

    private func runEntrance() {
        // Phase 1 — background + orbs
        withAnimation(.easeInOut(duration: 0.8)) {
            backgroundVisible = true
        }
        withAnimation(.easeInOut(duration: 1.5)) {
            orbsVisible = true
        }
        startOrbBreathing()

        // Phase 2 — brand (0.5s delay)
        withAnimation(.easeInOut(duration: 0.9).delay(0.5)) {
            brandVisible = true
        }

        // Phase 3 — logo compacts + form slides up (1.2s delay)
        withAnimation(.easeInOut(duration: 0.5).delay(1.2)) {
            logoCompact = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.4)) {
            formVisible = true
        }
    }

    private func startOrbBreathing() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            orb1Offset = -20
        }
        withAnimation(.easeInOut(duration: 3.5).delay(0.4).repeatForever(autoreverses: true)) {
            orb2Offset = -15
        }
        withAnimation(.easeInOut(duration: 4).delay(0.8).repeatForever(autoreverses: true)) {
            orb3Offset = -25
        }
    }
}

// MARK: - Supporting field views

private struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.white)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.white)
                    .textInputAutocapitalization(.never)
                    .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.08))
        )
    }
}

private struct AuthSecureField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var showText: Bool
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20)

            if showText {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(.white)
            }

            Button {
                showText.toggle()
            } label: {
                Image(systemName: showText ? "eye.slash" : "eye")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.08))
        )
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
