//
//  SearchViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 10/14/25.
//
import Foundation
import Combine

enum SearchScope: String, CaseIterable, Identifiable {
    case users = "Users"
    case restaurants = "Restaurants"
    var id: String { rawValue }
}

@MainActor
final class SearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var userResults: [UserPublic] = []
    @Published var restaurantResults: [RestaurantPublic] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var scope: SearchScope = .restaurants
    
    private let restaurantRepo = RestaurantRepository()
    private let userRepo = AppUserRepository()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        //Debounce user typing
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(350), scheduler: DispatchQueue.main)
            .sink{ [weak self] text in
                Task { await self?.performSearch(text) }
            }
            .store(in: &cancellables)
    }
    
    func performSearch(_ text: String) async {
        errorMessage = ""
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            userResults = []
            restaurantResults = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        switch scope {
        case .users:
            do {
                let users = try await userRepo.searchUsers(prefix: q, limit: 20)
                userResults = users
                restaurantResults = []
            } catch {
                errorMessage = error.localizedDescription
                userResults = []
                restaurantResults = []
            }
            
        case .restaurants:
            do {
                let restaurants = try await restaurantRepo.searchRestaurants(prefix: q, limit: 20)
                restaurantResults = restaurants
                userResults = []
            } catch {
                errorMessage = error.localizedDescription
                userResults = []
                restaurantResults = []
            }
        }
    }
}

