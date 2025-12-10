//
//  RestaurantViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 12/9/25.
//

import Foundation

@MainActor
final class RestaurantViewModel: ObservableObject {
    @Published var restaurant: RestaurantPublic?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let repo = RestaurantRepository()
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
        } catch {
            errorMessage = error.localizedDescription
        }
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

