// Features/Profile/PublicProfileView.swift
import SwiftUI

struct PublicProfileView: View {
    @StateObject private var vm: PublicProfileViewModel
    
    init(userId: String) {
        _vm = StateObject(wrappedValue: PublicProfileViewModel(userId: userId))
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
                                AsyncImage(url: URL(string: user.profilePicture ?? "")) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Circle().fill(Color.gray.opacity(0.2))
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
                            
                            // You can add sections here: lists/reviews/likes preview, etc.
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
