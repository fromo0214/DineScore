//
//  UserActivity.swift
//  DineScore
//
//  Created for recent activity feature
//

import Foundation
import FirebaseFirestore

enum ActivityType: String, Codable {
    case likedRestaurant = "liked_restaurant"
    case likedReview = "liked_review"
    case createdReview = "created_review"
}

struct UserActivity: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var type: ActivityType
    var restaurantId: String?
    var restaurantName: String?
    var reviewId: String?
    @ServerTimestamp var createdAt: Timestamp?
    
    // Computed property for sorting and display
    var timestamp: Date {
        createdAt?.dateValue() ?? Date()
    }
}
