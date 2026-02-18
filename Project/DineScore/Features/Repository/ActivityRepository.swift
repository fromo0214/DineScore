//
//  ActivityRepository.swift
//  DineScore
//
//  Created for recent activity feature
//

import Foundation
import FirebaseFirestore

final class ActivityRepository {
    private let db = Firestore.firestore()
    
    private var activities: CollectionReference {
        db.collection("activities")
    }
    
    // Create a new activity
    func createActivity(
        userId: String,
        type: ActivityType,
        restaurantId: String? = nil,
        restaurantName: String? = nil,
        reviewId: String? = nil
    ) async throws {
        let activity = UserActivity(
            id: nil,
            userId: userId,
            type: type,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            reviewId: reviewId,
            createdAt: nil
        )
        
        let newRef = activities.document()
        let data = try Firestore.Encoder().encode(activity)
        try await newRef.setData(data)
    }
    
    // Fetch recent activities for a user
    func fetchRecentActivities(userId: String, limit: Int = 10) async throws -> [UserActivity] {
        let snapshot = try await activities
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: UserActivity.self)
        }
    }

    // Listen for recent activities for a single user (live updates)
    func listenRecentActivities(
        userId: String,
        limit: Int = 20,
        onUpdate: @escaping ([UserActivity]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        return activities
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error)
                    return
                }
                let docs = snapshot?.documents ?? []
                let items = docs.compactMap { try? $0.data(as: UserActivity.self) }
                onUpdate(items)
            }
    }

    // Listen for recent activities for multiple users (live updates)
    func listenRecentActivities(
        userIds: [String],
        limit: Int = 20,
        onUpdate: @escaping ([UserActivity]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration? {
        guard !userIds.isEmpty else {
            onUpdate([])
            return nil
        }

        return activities
            .whereField("userId", in: userIds)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error)
                    return
                }
                let docs = snapshot?.documents ?? []
                let items = docs.compactMap { try? $0.data(as: UserActivity.self) }
                onUpdate(items)
            }
    }
}
