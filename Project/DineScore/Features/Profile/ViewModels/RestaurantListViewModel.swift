//
//  RestaurantListViewModel.swift
//  DineScore
//
//  Created for restaurant list feature
//

import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
final class RestaurantListViewModel: ObservableObject {
    @Published var lists: [RestaurantList] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let listRepo = RestaurantListRepository()
    private let restaurantRepo = RestaurantRepository()
    
    // Fetch all lists for the current user
    func fetchLists() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            lists = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            lists = try await listRepo.fetchUserLists(ownerId: uid)
        } catch {
            errorMessage = "Failed to load lists: \(error.localizedDescription)"
            lists = []
        }
    }
    
    // Create a new list
    func createList(name: String, description: String?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "RestaurantList", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let newList = RestaurantList.new(name: name, description: description, ownerId: uid)
        _ = try await listRepo.createList(newList)
        await fetchLists()
    }
    
    // Delete a list
    func deleteList(_ list: RestaurantList) async {
        guard let id = list.id else { return }
        
        do {
            try await listRepo.deleteList(id: id)
            lists.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete list: \(error.localizedDescription)"
        }
    }
    
    // Add restaurant to list
    func addRestaurantToList(listId: String, restaurantId: String) async throws {
        try await listRepo.addRestaurantToList(listId: listId, restaurantId: restaurantId)
        await fetchLists()
    }
    
    // Remove restaurant from list
    func removeRestaurantFromList(listId: String, restaurantId: String) async throws {
        try await listRepo.removeRestaurantFromList(listId: listId, restaurantId: restaurantId)
        await fetchLists()
    }
    
    // Fetch restaurant details for a list
    func fetchRestaurantsForList(_ list: RestaurantList) async -> [RestaurantPublic] {
        let ids = list.restaurantIds
        guard !ids.isEmpty else { return [] }
        
        let results: [RestaurantPublic?] = await withTaskGroup(of: RestaurantPublic?.self) { group in
            for id in ids {
                group.addTask { [restaurantRepo] in
                    do {
                        return try await restaurantRepo.fetchRestaurant(id: id)
                    } catch {
                        return nil
                    }
                }
            }
            var collected: [RestaurantPublic?] = []
            for await r in group {
                collected.append(r)
            }
            return collected
        }
        
        return results.compactMap { $0 }.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
}
