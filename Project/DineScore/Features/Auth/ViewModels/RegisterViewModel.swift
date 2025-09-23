//
//  RegisterViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 9/22/25.
//
//  Calls AuthService to actually create accounts

import Foundation

@MainActor
final class RegisterViewModel: ObservableObject{
    //Bound to text fields in your sign up view
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var zipCode = ""
    @Published var errorMessage = ""
    @Published var emailMessage = ""
    
    
    private let authService = AuthService()
    
    func register() async {
        guard !firstName.isEmpty, !lastName.isEmpty else{
            errorMessage = "Please enter your first and last name."
            return
        }
        
        guard password == confirmPassword else{
            errorMessage = "Passwords do not match."
            return
        }
       
        guard zipCode.count == 5, zipCode.allSatisfy(\.isNumber) else{
            errorMessage = "Please enter a valid zip code."
            return
        }
        
        errorMessage = ""
        emailMessage = ""
        
        do {
            try await authService.signUp(firstName: firstName, lastName: lastName, email: email, password: password, zipCode: zipCode)
            emailMessage = "Verification email sent! Check your inbox."
        } catch{
            errorMessage = error.localizedDescription
        }
    }
}
