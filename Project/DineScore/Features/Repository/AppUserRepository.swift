//
//  AppUserRepository.swift
//  DineScore
//
//  Created by Fernando Romo on 9/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class AppUserRepository{
    private let db = Firestore.firestore()
    
    //reference to the users collection in firestore
    private var users: CollectionReference { db.collection("users") }
    
    //get a users document by uid
    func get(uid: String) async throws -> AppUser? {
        let ref = users.document(uid)
        let snap = try await ref.getDocument()
        return try snap.data(as: AppUser?.self)
    }
    
    //create a new user document
    func create(user: AppUser) async throws {
        guard let uid = user.id else { throw NSError(domain: "AppUser", code: -1)}
        try users.document(uid).setData(from: user, merge: false)
    }
    
    //create or update existing user
    func upsert(user: AppUser) async throws {
        guard let uid = user.id else { throw NSError(domain: "AppUser", code: -1)}
        try users.document(uid).setData(from: user, merge: true)
    }
    
    func updateLastLogin(uid: String) async throws{
        try await users.document(uid).setData(["lastLoginAt": Date()], merge: true)
    }
    
}

