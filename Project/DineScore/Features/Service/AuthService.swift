//
//  AuthService.swift
//  DineScore
//
//  Created by Fernando Romo on 9/22/25.
//Handles firebase authentication (sign up, sign in).
//Also ensure a firebase user document is created/updated

import Foundation
import FirebaseAuth

@MainActor
final class AuthService: ObservableObject{
    private let repo = AppUserRepository()
    
    //Sign up: create Firebase Auth Account + Firebase Profile
    func signUp(firstName: String, lastName : String, email: String, password: String, zipCode: String) async throws {
        //Create auth account
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        
        //Build AppUser model with defaults
        let newUser = AppUser.new(uid: uid, firstName: firstName, lastName: lastName, email: email, zipCode: zipCode)
        
        //Save to Firestore
        try await repo.create(user: newUser)
        
        //email verification
        try await result.user.sendEmailVerification()
    }
    
    //Sign in: login with Firebase Auth and ensure Firestore doc exists
    func signIn(email: String, password: String) async throws{
        //Firebase Auth login
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid
        
        //Check if Firestore user doc exists
        if let _ = try await repo.get(uid: uid) {
            //if found, update last login time
            try await repo.updateLastLogin(uid: uid)
        }
    }
    
   
}
