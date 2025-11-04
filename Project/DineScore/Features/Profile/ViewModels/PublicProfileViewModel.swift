// Features/Profile/PublicProfileViewModel.swift
import Foundation

@MainActor
final class PublicProfileViewModel: ObservableObject {
    @Published var user: UserPublic?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let repo = AppUserRepository()
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await repo.fetchUser(id: userId)
            if user == nil { errorMessage = "User not found." }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
