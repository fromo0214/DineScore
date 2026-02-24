//
//  RestaurantReviewsViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 1/20/26.
//
import Foundation
import FirebaseAuth

@MainActor
final class RestaurantReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var usersById: [String: UserPublic] = [:]
    @Published var likedReviewIds: Set<String> = []
    @Published var likingReviewIds: Set<String> = []

    
    private let reviewRepo = ReviewRepository()
    private let userRepo = AppUserRepository() // Add this
    @Published private var reviewerLevels: [String: ReviewerLevel] = [:]

    func loadReviews(for restaurantId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            reviews = try await reviewRepo.fetchReviewsForRestaurant(restaurantId, limit: 50)
            reviews.sort { lhs, rhs in
                let lhsDate = lhs.createdAt?.dateValue() ?? .distantPast
                let rhsDate = rhs.createdAt?.dateValue() ?? .distantPast
                return lhsDate > rhsDate
            }
            
            // After loading reviews, fetch user data
            await loadReviewerLevels()
            await loadUsersForReviews()
            await refreshLikedReviews()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadUsersForReviews() async {
        // Get unique user IDs from reviews
        let userIds = Set(reviews.map { $0.userId })
        
        // Fetch users concurrently
        await withTaskGroup(of: (String, UserPublic?).self) { group in
            for userId in userIds {
                group.addTask {
                    do {
                        let user = try await self.userRepo.fetchUser(id: userId)
                        return (userId, user)
                    } catch {
                        print("Failed to fetch user \(userId): \(error)")
                        return (userId, nil)
                    }
                }
            }
            
            // Collect results
            for await (userId, user) in group {
                if let user = user {
                    usersById[userId] = user
                }
            }
        }
    }

    func refreshLikedReviews() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            likedReviewIds = []
            return
        }
        do {
            let liked = try await userRepo.getLikedReviews(uid: uid)
            likedReviewIds = Set(liked)
        } catch {
            likedReviewIds = []
        }
    }

    func toggleReviewLike(_ review: Review) async {
        guard let reviewId = review.id, !reviewId.isEmpty else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Sign in to like reviews."
            return
        }
        guard !likingReviewIds.contains(reviewId) else { return }
        likingReviewIds.insert(reviewId)
        defer { likingReviewIds.remove(reviewId) }
        let originalLiked = likedReviewIds.contains(reviewId)
        let originalCount = review.likeCount ?? 0
        do {
            if originalLiked {
                try await userRepo.unlikeReview(uid: uid, reviewId: reviewId)
                likedReviewIds.remove(reviewId)
            } else {
                try await userRepo.likeReview(uid: uid, reviewId: reviewId)
                likedReviewIds.insert(reviewId)
            }
            await refreshLikeCount(reviewId: reviewId, fallbackCount: originalCount)
        } catch {
            errorMessage = "Failed to update like: \(error.localizedDescription)"
            if originalLiked {
                likedReviewIds.insert(reviewId)
            } else {
                likedReviewIds.remove(reviewId)
            }
            await refreshLikeCount(reviewId: reviewId, fallbackCount: originalCount)
        }
    }
    
    func canDeleteReview(_ review: Review) -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return review.userId == uid
    }
    
    func deleteReview(_ review: Review) async {
        guard let reviewId = review.id, !reviewId.isEmpty else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Sign in to delete your review."
            return
        }
        guard review.userId == uid else {
            errorMessage = "You can only delete your own reviews."
            return
        }
        do {
            try await reviewRepo.deleteReview(id: reviewId, userId: uid)
            if let index = reviews.firstIndex(where: { $0.id == reviewId }) {
                reviews.remove(at: index)
            }
            likedReviewIds.remove(reviewId)
        } catch {
            errorMessage = "Failed to delete review: \(error.localizedDescription)"
        }
    }

    private func refreshLikeCount(reviewId: String, fallbackCount: Int) async {
        do {
            if let review = try await reviewRepo.fetchReview(id: reviewId),
               let index = reviews.firstIndex(where: { $0.id == reviewId }) {
                reviews[index].likeCount = review.likeCount ?? fallbackCount
            }
        } catch {
            if let index = reviews.firstIndex(where: { $0.id == reviewId }) {
                reviews[index].likeCount = fallbackCount
            }
        }
    }
    
    var averageFoodScore: Double {
        let foodScores = reviews.compactMap { $0.foodScore }
        guard !foodScores.isEmpty else { return 0.0 }
        return foodScores.reduce(0, +) / Double(foodScores.count)
    }

    var averageServiceScore: Double {
        let serviceScores = reviews.compactMap { $0.serviceScore }
        guard !serviceScores.isEmpty else { return 0.0 }
        return serviceScores.reduce(0, +) / Double(serviceScores.count)
    }

    func badgeLabel(for userId: String) -> String? {
        reviewerLevels[userId]?.badge.rawValue
    }

    private func loadReviewerLevels() async {
        let userIds = Set(reviews.map { $0.userId })
        guard !userIds.isEmpty else {
            reviewerLevels = [:]
            return
        }
        var levels: [String: ReviewerLevel] = [:]
        await withTaskGroup(of: (String, ReviewerLevel?).self) { group in
            for userId in userIds {
                group.addTask { [reviewRepo] in
                    do {
                        let userReviews = try await reviewRepo.fetchReviewsByUser(userId, limit: 200)
                        return (userId, ReviewerLevelCalculator.level(from: userReviews))
                    } catch {
                        return (userId, nil)
                    }
                }
            }
            for await (userId, level) in group {
                if let level {
                    levels[userId] = level
                }
            }
        }
        reviewerLevels = levels
    }
}
