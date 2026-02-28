//
//  AuthManager.swift
//  Wombitious
//

import Foundation
import CryptoKit

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Incorrect email or password."
        case .emailAlreadyExists: return "An account already exists. Please log in."
        case .weakPassword:       return "Password must be at least 6 characters."
        case .invalidEmail:       return "Please enter a valid email address."
        }
    }
}

final class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var currentUserEmail: String

    private enum Keys {
        static let isLoggedIn  = "wombitious.isLoggedIn"
        static let userEmail   = "wombitious.userEmail"
        static let hasAccount  = "wombitious.hasAccount"
        static let passwordHash = "wombitious.password.hash"
    }

    var hasExistingAccount: Bool {
        UserDefaults.standard.bool(forKey: Keys.hasAccount)
    }

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: Keys.isLoggedIn)
        currentUserEmail = UserDefaults.standard.string(forKey: Keys.userEmail) ?? ""
    }

    func signUp(email: String, password: String) throws {
        guard isValidEmail(email)    else { throw AuthError.invalidEmail }
        guard password.count >= 6    else { throw AuthError.weakPassword }
        guard !hasExistingAccount    else { throw AuthError.emailAlreadyExists }

        let hash = sha256(password)
        KeychainService.save(key: Keys.passwordHash, value: hash)

        UserDefaults.standard.set(true,  forKey: Keys.hasAccount)
        UserDefaults.standard.set(email, forKey: Keys.userEmail)
        setAuthenticated(email: email)
    }

    func login(email: String, password: String) throws {
        guard isValidEmail(email) else { throw AuthError.invalidEmail }

        let storedHash  = KeychainService.load(key: Keys.passwordHash) ?? ""
        let attemptHash = sha256(password)

        guard attemptHash == storedHash else { throw AuthError.invalidCredentials }

        UserDefaults.standard.set(email, forKey: Keys.userEmail)
        setAuthenticated(email: email)
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: Keys.isLoggedIn)
        isAuthenticated  = false
        currentUserEmail = ""
    }

    // MARK: - Private

    private func setAuthenticated(email: String) {
        UserDefaults.standard.set(true, forKey: Keys.isLoggedIn)
        currentUserEmail = email
        isAuthenticated  = true
    }

    private func sha256(_ input: String) -> String {
        let data   = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func isValidEmail(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
}
