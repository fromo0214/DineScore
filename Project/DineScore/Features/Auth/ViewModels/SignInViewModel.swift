//
//  SignInViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 9/22/25.
//

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let authService = AuthService()
    
    /// Sign in with email & password via AuthService.
    /// If this succeeds, AuthService ensures the Firestore user doc exists
    /// and updates lastLoginAt. Your view just flips userIsLoggedIn.
    
    func signIn() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signIn(email: email, password: password)
            errorMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
            print("Login Error: \(errorMessage)")
        }
    }
    
}
