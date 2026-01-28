//
//  FollowButton.swift
//  DineScore
//
//  Follow/Unfollow button component for user profiles
//

import SwiftUI
import FirebaseAuth

struct FollowButton: View {
    @ObservedObject var viewModel: PublicProfileViewModel
    @State private var showError = false
    
    var body: some View {
        // Don't show button if viewing own profile
        if let currentUserId = Auth.auth().currentUser?.uid,
           currentUserId == viewModel.userId {
            EmptyView()
        } else {
            VStack(spacing: 4) {
                Button(action: {
                    Task {
                        await viewModel.toggleFollow()
                        if !viewModel.errorMessage.isEmpty {
                            showError = true
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        if viewModel.isFollowActionInProgress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(viewModel.isFollowing ? "Following" : "Follow")
                                .font(.subheadline)
                                .bold()
                        }
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 100)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(viewModel.isFollowing ? Color.gray : Color.accentColor)
                    .cornerRadius(8)
                }
                .disabled(viewModel.isFollowActionInProgress)
                
                if showError && !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
        }
    }
}
