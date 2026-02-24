//
//  ReviewRepository.swift
//  DineScore
//
//  Created by Fernando Romo on 12/16/25.
// ReviewRepository: implement createReview that creates a Firestore review document, uploads multiple images, then patches the document with the array of download URLs. Also add some basic fetch helpers.

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ReviewRepository{
    enum ReviewRepositoryError: LocalizedError {
        case notAuthorizedToDelete
        
        var errorDescription: String? {
            switch self {
            case .notAuthorizedToDelete:
                return "You can only delete your own reviews."
            }
        }
    }
    
    private let db = Firestore.firestore()
    private let uploader = ImageUploader()
    private let activityRepo = ActivityRepository()
    private let restaurantRepo = RestaurantRepository()
    
    // Top-level "reviews" collection. Each doc stores restaurantId and userId fields.
    private var reviews: CollectionReference { db.collection("reviews") }
    
    // Create a review with optional multiple images. Returns the new reviewId.
    @MainActor
    func createReview(
        restaurantId: String,
        userId: String,
        foodScore: Double?,
        serviceScore: Double?,
        foodText: String?,
        serviceText: String?,
        visitedAt: Date?,
        comeBack: ComeBackOption?,
        priceValue: PriceValueOption?,
        tags: [String]?,
        images: [UIImage]
    ) async throws -> String {
        
        // 1) Create a new document to obtain its ID
        let newRef = reviews.document()
        let reviewId = newRef.documentID
        
        // 2) Save base review (without media URLs yet)
        let base = Review(
            id: reviewId,
            restaurantId: restaurantId,
            userId: userId,
            foodScore: foodScore,
            serviceScore: serviceScore,
            foodText: foodText,
            serviceText: serviceText,
            mediaURLS: nil,
            visitedAt: visitedAt,
            comeBack: comeBack,
            priceValue: priceValue,
            tags: tags,
            likeCount: 0,
            createdAt: nil,
            updatedAt: nil
        )
        
        let baseData = try Firestore.Encoder().encode(base)
        var initialData = baseData
        initialData["createdAt"] = FieldValue.serverTimestamp()
        try await newRef.setData(initialData, merge: false)
        
        // 3) Upload images (if any)
        var urls: [String] = []
        if !images.isEmpty {
            urls = try await uploader.uploadReviewImages(images, reviewId: reviewId)
        }
        
        // 4) Patch the review with media URLs and updatedAt
        if !urls.isEmpty {
            try await newRef.updateData([
                "mediaURLS": urls,
                "updatedAt": FieldValue.serverTimestamp()
            ])
        } else {
            // still bump updatedAt so we have a complete record
            try await newRef.updateData([
                "updatedAt": FieldValue.serverTimestamp()
            ])
        }
        
        // 5) Create activity for creating review (non-critical, don't fail if this errors)
        do {
            let restaurant = try await restaurantRepo.fetchRestaurant(id: restaurantId)
            try await activityRepo.createActivity(
                userId: userId,
                type: .createdReview,
                restaurantId: restaurantId,
                restaurantName: restaurant?.name,
                reviewId: reviewId
            )
        } catch {
            // Log the error but don't fail the entire operation
            print("Warning: Failed to create activity for review creation: \(error.localizedDescription)")
        }
        
        return reviewId
    }
    
    // Fetch recent reviews for a restaurant
    func fetchReviewsForRestaurant(_ restaurantId: String, limit: Int = 20) async throws -> [Review] {
        let q: Query
        if limit > 0 {
            q = reviews
                .whereField("restaurantId", isEqualTo: restaurantId)
                .limit(to: limit)
        } else {
            q = reviews
                .whereField("restaurantId", isEqualTo: restaurantId)
        }
        let snap = try await q.getDocuments()
        return try snap.documents.compactMap { doc in
            try doc.data(as: Review.self)
        }
    }
    
    // Fetch recent reviews written by a user
    func fetchReviewsByUser(_ userId: String, limit: Int = 20) async throws -> [Review] {
        let snap = try await reviews
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return try snap.documents.compactMap { doc in
            try doc.data(as: Review.self)
        }
    }

    func fetchReview(id: String) async throws -> Review? {
        let snap = try await reviews.document(id).getDocument()
        guard snap.exists else { return nil }
        return try snap.data(as: Review.self)
    }
    
    func deleteReview(id: String, userId: String) async throws {
        let ref = reviews.document(id)
        guard let review = try await fetchReview(id: id) else { return }
        guard review.userId == userId else {
            throw ReviewRepositoryError.notAuthorizedToDelete
        }
        try await ref.delete()
    }

}
