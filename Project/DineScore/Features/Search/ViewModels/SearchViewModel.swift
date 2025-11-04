//
//  SearchViewModel.swift
//  DineScore
//
//  Created by Fernando Romo on 10/14/25.
//
import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var results: [UserPublic] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let repo = AppUserRepository()
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
        print("Searching for:", text)
        errorMessage = ""
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            return
        }
        isLoading = true
        do {
            let users = try await repo.searchUsers(prefix: text, limit: 20)
            print("Users returned:", users.count)
            results = users
        } catch{
            print("Search Error", error)
            errorMessage = error.localizedDescription
            results = []
        }
        isLoading = false
    }
}
