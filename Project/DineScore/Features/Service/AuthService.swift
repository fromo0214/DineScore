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
        try await ensureUserDocument(for: result.user)
    }
    
    func signInWithGoogle(idToken: String, accessToken: String) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        try await signIn(with: credential)
    }
    
    func signInWithFacebook(accessToken: String) async throws {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        try await signIn(with: credential)
    }
    
    func signInWithApple(idToken: String, rawNonce: String) async throws {
        let credential = OAuthProvider.credential(providerID: "apple.com", idToken: idToken, rawNonce: rawNonce)
        try await signIn(with: credential)
    }
    
    private func signIn(with credential: AuthCredential) async throws {
        let result = try await Auth.auth().signIn(with: credential)
        try await ensureUserDocument(for: result.user)
    }
    
    private func ensureUserDocument(for user: User) async throws {
        if let _ = try await repo.get(uid: user.uid) {
            try await repo.updateLastLogin(uid: user.uid)
            return
        }
        
        let nameParts = (user.displayName ?? "").split(separator: " ")
        let firstName = nameParts.first.map(String.init).flatMap { $0.isEmpty ? nil : $0 } ?? "DineScore"
        let lastName = nameParts.dropFirst().joined(separator: " ").isEmpty ? "User" : nameParts.dropFirst().joined(separator: " ")
        
        let newUser = AppUser(
            id: user.uid,
            firstName: firstName,
            lastName: lastName,
            email: user.email ?? "",
            profileImageURL: user.photoURL?.absoluteString,
            bio: nil,
            level: 1,
            zipCode: nil,
            likedRestaurants: [],
            likedReviews: [],
            followers: [],
            following: [],
            joinedDate: Date(),
            lastLoginAt: Date()
        )
        
        try await repo.create(user: newUser)
    }
    
   
}
