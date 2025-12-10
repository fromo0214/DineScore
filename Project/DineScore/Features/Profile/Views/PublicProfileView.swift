// Features/Profile/PublicProfileView.swift
import SwiftUI

struct PublicProfileView: View {
    @StateObject private var vm: PublicProfileViewModel
    
    init(userId: String) {
        _vm = StateObject(wrappedValue: PublicProfileViewModel(userId: userId))
    }
    
    // Build a dynamic title using normalized names, with a safe fallback
    private var navTitle: String {
        if let user = vm.user {
            let combined = user.displayNameShort
            return combined.isEmpty ? "Profile" : combined
        } else {
            return "Profile"
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            
            SwiftUI.Group {
                if vm.isLoading {
                    SwiftUI.ProgressView("Loading Profile…")
                } else if let user = vm.user {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header
                            VStack(spacing: 10) {
                                let url = user.profilePicture.flatMap { URL(string: $0) }
                                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 0.15))) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable()
                                            .scaledToFill()
                                            .transition(.opacity)
                                    case .empty:
                                        Circle().fill(Color.gray.opacity(0.2))
                                    case .failure:
                                        ZStack {
                                            Circle().fill(Color.gray.opacity(0.2))
                                            Text(initials(from: user))
                                                .font(.title3).bold()
                                                .foregroundColor(.secondary)
                                        }
                                    @unknown default:
                                        Circle().fill(Color.gray.opacity(0.2))
                                    }
                                }
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                
                                Text(user.displayNameShort)
                                    .font(.title3).bold()
                                Text("@\(user.username)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
//                                FollowButton(targetUserId: user.id)
                            }
                            .padding(.top, 20)
                            
                            if let bio = user.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Add sections (lists/reviews/likes) as needed
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage).foregroundColor(.red)
                } else {
                    Text("User not found").foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .task { await vm.load() }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func initials(from user: UserPublic) -> String {
        let f = user.firstName.first.map { String($0) } ?? ""
        let l = user.lastName.first.map { String($0) } ?? ""
        return (f + l).uppercased()
    }
}

