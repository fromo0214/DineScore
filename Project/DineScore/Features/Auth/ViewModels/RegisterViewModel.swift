//
//  RegisterViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 9/22/25.
//
// Calls AuthService to actually create accounts

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
       
    }
}
