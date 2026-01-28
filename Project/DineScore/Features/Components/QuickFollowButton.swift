//
//  QuickFollowButton.swift
//  DineScore
//
//  Quick follow/unfollow button for use in user lists and search results
//

import SwiftUI
import FirebaseAuth

struct QuickFollowButton: View {
    let targetUserId: String
    @State private var isFollowing = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    private let repo = AppUserRepository()
    
    var body: some View {
        // Don't show button if viewing own profile
        if let currentUserId = Auth.auth().currentUser?.uid,
           currentUserId == targetUserId {
            EmptyView()
        } else {
            Button(action: {
                Task {
                    await toggleFollow()
                }
            }) {
                HStack(spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.7)
                    } else {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.caption)
                            .bold()
                    }
                }
                .foregroundColor(.white)
                .frame(minWidth: 80)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isFollowing ? Color.gray : Color.accentColor)
                .cornerRadius(6)
            }
            .disabled(isLoading)
            .task {
                await checkFollowingStatus()
            }
        }
    }
    
    private func checkFollowingStatus() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            isFollowing = false
            return
        }
        
        guard currentUserId != targetUserId else {
            isFollowing = false
            return
        }
        
        do {
            isFollowing = try await repo.isFollowing(currentUserId: currentUserId, targetUserId: targetUserId)
        } catch {
            print("Error checking following status: \(error.localizedDescription)")
            isFollowing = false
        }
    }
    
    private func toggleFollow() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to follow users."
            return
        }
        
        guard currentUserId != targetUserId else {
            return
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if isFollowing {
                try await repo.unfollowUser(currentUserId: currentUserId, targetUserId: targetUserId)
                isFollowing = false
            } else {
                try await repo.followUser(currentUserId: currentUserId, targetUserId: targetUserId)
                isFollowing = true
            }
        } catch {
            errorMessage = "Failed to update follow status: \(error.localizedDescription)"
            print(errorMessage)
        }
    }
}
