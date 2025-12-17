//
//  RestaurantViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 12/9/25.
//

import Foundation
import FirebaseAuth

@MainActor
final class RestaurantViewModel: ObservableObject {
    @Published var restaurant: RestaurantPublic?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // Likes state
    @Published var isLiked = false
    @Published var isLiking = false
    
    private let repo = RestaurantRepository()
    private let userRepo = AppUserRepository()
    let restaurantId: String
    
    init(restaurantId: String) {
        self.restaurantId = restaurantId
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            restaurant = try await repo.fetchRestaurant(id: restaurantId)
            if let urlStr = restaurant?.coverPicture {
                prefetch(urlString: urlStr)
            }
            if restaurant == nil { errorMessage = "Restaurant not found." }
            // Also load like state for current user
            await loadLikeState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadLikeState() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLiked = false
            return
        }
        do {
            let liked = try await userRepo.getLikedRestaurants(uid: uid)
            isLiked = liked.contains(restaurantId)
            // Debug if needed:
            // print("Liked list:", liked, "RestaurantId:", restaurantId, "isLiked:", isLiked)
        } catch {
            isLiked = false
        }
    }
    
    func toggleLike() async {
        guard !isLiking else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Please sign in to like restaurants."
            return
        }
        isLiking = true
        let newValue = !isLiked
        // Optimistic update
        isLiked = newValue
        do {
            if newValue {
                try await userRepo.likeRestaurant(uid: uid, restaurantId: restaurantId)
            } else {
                try await userRepo.unlikeRestaurant(uid: uid, restaurantId: restaurantId)
            }
        } catch {
            // Roll back on failure
            isLiked.toggle()
            errorMessage = error.localizedDescription
        }
        isLiking = false
    }
    
    private func prefetch(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        Task.detached(priority: .utility) {
            var req = URLRequest(url: url)
            req.cachePolicy = .returnCacheDataElseLoad
            _ = try? await URLSession.shared.data(for: req)
        }
    }
}

