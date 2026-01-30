// Features/Profile/PublicProfileViewModel.swift
import Foundation
import FirebaseAuth

@MainActor
final class PublicProfileViewModel: ObservableObject {
    @Published var user: UserPublic?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isFollowing = false
    @Published var isFollowActionInProgress = false
    
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
            if let urlStr = user?.profilePicture {
                prefetch(urlString: urlStr)
            }
            if user == nil { 
                errorMessage = "User not found." 
            } else {
                // Check if current user is following this profile
                await checkFollowingStatus()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func checkFollowingStatus() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            isFollowing = false
            return
        }
        
        // Don't check if viewing own profile
        guard currentUserId != userId else {
            isFollowing = false
            return
        }
        
        do {
            isFollowing = try await repo.isFollowing(currentUserId: currentUserId, targetUserId: userId)
        } catch {
            print("Error checking following status: \(error.localizedDescription)")
            isFollowing = false
        }
    }
    
    func toggleFollow() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to follow users."
            return
        }
        
        guard currentUserId != userId else {
            errorMessage = "You cannot follow yourself."
            return
        }
        
        guard !isFollowActionInProgress else { return }
        
        isFollowActionInProgress = true
        defer { isFollowActionInProgress = false }
        
        do {
            if isFollowing {
                try await repo.unfollowUser(currentUserId: currentUserId, targetUserId: userId)
                isFollowing = false
            } else {
                try await repo.followUser(currentUserId: currentUserId, targetUserId: userId)
                isFollowing = true
            }
        } catch {
            errorMessage = "Failed to update follow status: \(error.localizedDescription)"
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

