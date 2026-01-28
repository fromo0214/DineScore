//
//  RestaurantReviewsViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 1/20/26.
//
import Foundation

@MainActor
final class RestaurantReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var usersById: [String: UserPublic] = [:]

    
    private let reviewRepo = ReviewRepository()
    private let userRepo = AppUserRepository() // Add this

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
            await loadUsersForReviews()
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
}
