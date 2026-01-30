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
    private let activityRepo = ActivityRepository()
    private let restaurantRepo = RestaurantRepository()
    
    //reference to the users collection in firestore
    private var users: CollectionReference { db.collection("users") }
    private var reviews: CollectionReference { db.collection("reviews") }
    
    // Fetch a public user by id
    func fetchUser(id: String) async throws -> UserPublic? {
        let snap = try await users.document(id).getDocument()
        guard snap.exists else { return nil }
        return try snap.data(as: UserPublic.self)
    }

    func searchUsers(prefix: String, limit: Int = 20) async throws -> [UserPublic] {
        let q = prefix.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        
        async let usernames = try queryPrefix(field: "username_normalized", q: q, limit: limit)
        async let firstNames = try queryPrefix(field: "firstName_normalized", q: q, limit: limit)
        async let lastNames = try queryPrefix(field: "lastName_normalized", q: q, limit: limit)
        
        var combined = try await (usernames + firstNames + lastNames)
        var seen = Set<String>()
        combined = combined.filter { seen.insert($0.id!).inserted }
        
        return Array(combined.prefix(limit))
    }
    
    private func queryPrefix(field: String, q: String, limit: Int) async throws -> [UserPublic] {
        let snapshot = try await users
            .order(by: field)
            .start(at: [q])
            .end(at: [q + "\u{f8ff}"])
            .limit(to: limit)
            .getDocuments()
        let results = snapshot.documents.compactMap{ doc in
            let data = doc.data()
            print("Raw data for user:", data)
            return try? doc.data(as: UserPublic.self)
        }
        return results
    }
    
    //get a users document by uid
    func get(uid: String) async throws -> AppUser? {
        let ref = users.document(uid)
        let snap = try await ref.getDocument()
        guard snap.exists else { return nil }
        return decodeAppUser(snapshot: snap)
    }

    private func decodeAppUser(snapshot: DocumentSnapshot) -> AppUser {
        let data = snapshot.data() ?? [:]
        let id = snapshot.documentID
        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let profileImageURL = (data["profileImageURL"] as? String) ?? (data["profilePicture"] as? String)
        let bio = data["bio"] as? String
        let level = (data["level"] as? NSNumber)?.intValue ?? (data["level"] as? Int) ?? 1
        let zipCode = data["zipCode"] as? String
        let likedRestaurants = data["likedRestaurants"] as? [String] ?? []
        let likedReviews = data["likedReviews"] as? [String] ?? []
        let followers = data["followers"] as? [String] ?? []
        let following = data["following"] as? [String] ?? []
        let joinedDate = (data["joinedDate"] as? Timestamp)?.dateValue()
            ?? (data["joinedDate"] as? Date)
            ?? Date()
        let lastLoginAt = (data["lastLoginAt"] as? Timestamp)?.dateValue()
            ?? (data["lastLoginAt"] as? Date)

        return AppUser(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            profileImageURL: profileImageURL,
            bio: bio,
            level: level,
            zipCode: zipCode,
            likedRestaurants: likedRestaurants,
            likedReviews: likedReviews,
            followers: followers,
            following: following,
            joinedDate: joinedDate,
            lastLoginAt: lastLoginAt
        )
    }
    
    //getter for likedRestaurants
    func getLikedRestaurants(uid: String) async throws -> [String] {
        let ref = users.document(uid)
        let snap = try await ref.getDocument()
        guard snap.exists else { return [] }
        // Safely coerce to [String]; default to [] if missing or wrong type
        return (snap.get("likedRestaurants") as? [String]) ?? []
    }

    func getLikedReviews(uid: String) async throws -> [String] {
        let ref = users.document(uid)
        let snap = try await ref.getDocument()
        guard snap.exists else { return [] }
        return (snap.get("likedReviews") as? [String]) ?? []
    }
    
    //create a new user document
    func create(user: AppUser) async throws {
        guard let uid = user.id else { throw NSError(domain: "AppUser", code: -1)}
        
        // Encode the AppUser data
        let baseData = try Firestore.Encoder().encode(user)
        
        // Derive public/normalized fields
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
        // Mirror to public field name used by UserPublic
        if let url = user.profileImageURL { merged["profilePicture"] = url }
        
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
        // Mirror to public field name used by UserPublic
        if let url = user.profileImageURL { merged["profilePicture"] = url }
        
        try await users.document(uid).setData(merged, merge: true)
    }
    
    func updateLastLogin(uid: String) async throws{
        try await users.document(uid).setData(["lastLoginAt": Date()], merge: true)
    }
    
    // MARK: - Likes helpers
    func likeRestaurant(uid: String, restaurantId: String) async throws {
        try await users.document(uid).updateData([
            "likedRestaurants": FieldValue.arrayUnion([restaurantId])
        ])
        
        // Create activity for liking restaurant (non-critical, don't fail if this errors)
        do {
            let restaurant = try await restaurantRepo.fetchRestaurant(id: restaurantId)
            try await activityRepo.createActivity(
                userId: uid,
                type: .likedRestaurant,
                restaurantId: restaurantId,
                restaurantName: restaurant?.name
            )
        } catch {
            // Log the error but don't fail the entire operation
            print("Warning: Failed to create activity for liking restaurant: \(error.localizedDescription)")
        }
    }
    
    func unlikeRestaurant(uid: String, restaurantId: String) async throws {
        try await users.document(uid).updateData([
            "likedRestaurants": FieldValue.arrayRemove([restaurantId])
        ])
    }
    
    // MARK: - Review Likes helpers
    func likeReview(uid: String, reviewId: String) async throws {
        try await updateReviewLike(uid: uid, reviewId: reviewId, shouldLike: true)
    }

    func unlikeReview(uid: String, reviewId: String) async throws {
        try await updateReviewLike(uid: uid, reviewId: reviewId, shouldLike: false)
    }

    private func updateReviewLike(uid: String, reviewId: String, shouldLike: Bool) async throws {
        let userRef = users.document(uid)
        let reviewRef = reviews.document(reviewId)
        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let userSnapshot = try transaction.getDocument(userRef)
                let reviewSnapshot = try transaction.getDocument(reviewRef)
                var liked = (userSnapshot.get("likedReviews") as? [String]) ?? []
                var likeCount = (reviewSnapshot.get("likeCount") as? Int) ?? 0
                if shouldLike {
                    if !liked.contains(reviewId) {
                        liked.append(reviewId)
                        likeCount += 1
                    }
                } else if let index = liked.firstIndex(of: reviewId) {
                    liked.remove(at: index)
                    likeCount = max(0, likeCount - 1)
                }
                transaction.updateData(["likedReviews": liked], forDocument: userRef)
                transaction.updateData(["likeCount": likeCount], forDocument: reviewRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            return nil
        }
    }
    
    // MARK: - Follow/Unfollow helpers
    
    /// Follow a user: adds targetUserId to current user's following list and adds currentUserId to target's followers list
    func followUser(currentUserId: String, targetUserId: String) async throws {
        guard currentUserId != targetUserId else {
            throw NSError(domain: "AppUserRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot follow yourself"])
        }
        
        let currentUserRef = users.document(currentUserId)
        let targetUserRef = users.document(targetUserId)
        
        try await db.runTransaction { transaction, errorPointer in
            // Add targetUserId to current user's following list
            transaction.updateData([
                "following": FieldValue.arrayUnion([targetUserId])
            ], forDocument: currentUserRef)
            
            // Add currentUserId to target user's followers list
            transaction.updateData([
                "followers": FieldValue.arrayUnion([currentUserId])
            ], forDocument: targetUserRef)
            
            return nil
        }
    }
    
    /// Unfollow a user: removes targetUserId from current user's following list and removes currentUserId from target's followers list
    func unfollowUser(currentUserId: String, targetUserId: String) async throws {
        guard currentUserId != targetUserId else {
            throw NSError(domain: "AppUserRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot unfollow yourself"])
        }
        
        let currentUserRef = users.document(currentUserId)
        let targetUserRef = users.document(targetUserId)
        
        try await db.runTransaction { transaction, errorPointer in
            // Remove targetUserId from current user's following list
            transaction.updateData([
                "following": FieldValue.arrayRemove([targetUserId])
            ], forDocument: currentUserRef)
            
            // Remove currentUserId from target user's followers list
            transaction.updateData([
                "followers": FieldValue.arrayRemove([currentUserId])
            ], forDocument: targetUserRef)
            
            return nil
        }
    }
    
    /// Check if current user is following target user
    func isFollowing(currentUserId: String, targetUserId: String) async throws -> Bool {
        let snapshot = try await users.document(currentUserId).getDocument()
        guard snapshot.exists else { return false }
        let following = (snapshot.get("following") as? [String]) ?? []
        return following.contains(targetUserId)
    }
}
