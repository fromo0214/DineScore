//
//  AuthViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 8/12/25.
//

import SwiftUI
import FirebaseAuth
@MainActor
final class AuthViewModel: ObservableObject{
    @Published var email = ""
    @Published var emailMessage = ""
    @Published var errorMessage = ""
    
    func sendResetLink() async{
        Auth.auth().sendPasswordReset(withEmail: email){ error in
            
            if let error = error as NSError?{
                
                //convert to Firebase AuthErrorCode
                if let errorCode = AuthErrorCode(rawValue: error.code){
                    switch errorCode{
                    case .invalidEmail, .invalidRecipientEmail:
                        self.errorMessage = "Invalid email address."
                    default:
                        self.errorMessage = "Something went wrong. Please try again."
                    }
                }else{
                    self.errorMessage = "Unexpected error occured."
                }
            }else{
                self.emailMessage = "Password reset link sent!"
                self.errorMessage = ""
            }
        }
    }
}
