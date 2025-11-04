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
    
    // Fetch a public user by id
    func fetchUser(id: String) async throws -> UserPublic? {
        let snap = try await users.document(id).getDocument()
        guard snap.exists else { return nil }
        return try snap.data(as: UserPublic.self)
    }

    func searchUsers(prefix: String, limit: Int = 20) async throws -> [UserPublic] {
        let q = prefix.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // Only return empty when the query is empty
        guard !q.isEmpty else { return [] }
        
        async let usernames = try queryPrefix(field: "username_normalized", q: q, limit: limit)
        async let firstNames = try queryPrefix(field: "firstName_normalized", q: q, limit: limit)
        async let lastNames = try queryPrefix(field: "lastName_normalized", q: q, limit: limit)
        
        var combined = try await (usernames + firstNames + lastNames)
        //remove duplicates by id
        var seen = Set<String>()
        combined = combined.filter { seen.insert($0.id!).inserted }
        
        return Array(combined.prefix(limit))
    }
    
    private func queryPrefix(field: String, q: String, limit: Int) async throws -> [UserPublic] {
        let snapshot = try await users
            .order(by: field)
            .start(at: [q])
            .end(at: [q + "\u{f8ff}"])
//            .whereField(field, isEqualTo: q)
            .limit(to: limit)
            .getDocuments()
        print("DEBUG: Query returned \(snapshot.documents.count)")
        let results = snapshot.documents.compactMap{ doc in
            let data = doc.data()
            print("Raw data for doc:", data)
            return try? doc.data(as: UserPublic.self)
        }
        print("DEBUG: Successfully decoded \(results.count) users")
        return results
    }
    
    //get a users document by uid
    func get(uid: String) async throws -> AppUser? {
        let ref = users.document(uid)
        let snap = try await ref.getDocument()
        return try snap.data(as: AppUser?.self)
    }
    
    //create a new user document
    func create(user: AppUser) async throws {
        guard let uid = user.id else { throw NSError(domain: "AppUser", code: -1)}
        
        // Encode the AppUser data
        let baseData = try Firestore.Encoder().encode(user)
        
        // Derive public/normalized fields
        let firstLower = user.firstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let lastLower  = user.lastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // If you have a username field elsewhere, use it. Otherwise derive from email prefix.
        let username = user.email.split(separator: "@").first.map(String.init) ?? ""
        let usernameLower = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        var merged: [String: Any] = baseData
        merged["firstName"] = user.firstName
        merged["lastName"] = user.lastName
        merged["username"] = username
        merged["firstName_normalized"] = firstLower
        merged["lastName_normalized"] = lastLower
        merged["username_normalized"] = usernameLower
        
        try await users.document(uid).setData(merged, merge: false)
    }
    
    //create or update existing user
    func upsert(user: AppUser) async throws {
        guard let uid = user.id else { throw NSError(domain: "AppUser", code: -1)}
        
        let baseData = try Firestore.Encoder().encode(user)
        let firstLower = user.firstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let lastLower  = user.lastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let username = user.email.split(separator: "@").first.map(String.init) ?? ""
        let usernameLower = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        var merged: [String: Any] = baseData
        merged["firstName"] = user.firstName
        merged["lastName"] = user.lastName
        merged["username"] = username
        merged["firstName_normalized"] = firstLower
        merged["lastName_normalized"] = lastLower
        merged["username_normalized"] = usernameLower
        
        try await users.document(uid).setData(merged, merge: true)
    }
    
    func updateLastLogin(uid: String) async throws{
        try await users.document(uid).setData(["lastLoginAt": Date()], merge: true)
    }
}
