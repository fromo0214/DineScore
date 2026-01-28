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
}
