//
//  UserSocialsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI
import FirebaseAuth

struct UserSocialsView: View {
    let currentUser: AppUser
    @ObservedObject var vm = UserProfileViewModel()
    
    init(currentUser: AppUser, vm: UserProfileViewModel) {
           self.currentUser = currentUser
        _vm = ObservedObject(wrappedValue: vm)
        _followers = State(initialValue: currentUser.followers)
        _following = State(initialValue: currentUser.following)
       }
    
    //dismisses the current view, used for back button
    @Environment(\.dismiss) var dismiss
    
    @State var selectedTab: SocialTab = .followers

    enum SocialTab: String, CaseIterable, Identifiable{
        case followers = "Followers"
        case following = "Following"
        var id: String { self.rawValue }
    }
    
    @State private var followers: [String] = []
    @State private var following: [String] = []
    @State private var usersById: [String: UserPublic] = [:]
    private let repo = AppUserRepository()

    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing:0){
                    //picker tab
                    Picker("Social Tab", selection: $selectedTab){
                        ForEach(SocialTab.allCases){tab in
                            Text(tab.rawValue).tag(tab)
                                .foregroundColor(.accentColor)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding(.top, 5)
                    
                    List{
                        ForEach(selectedTab == .followers ? followers : following, id: \.self) { userId in
                            let user = usersById[userId]
                            HStack{
                                NavigationLink(destination: PublicProfileView(userId: userId)) {
                                    HStack(spacing: 12){
                                        avatarView(for: user)
                                
                                        Text(user?.displayNameShort ?? "User")
                                            .foregroundColor(Color.accentColor)
                                    }
                                }
                                Spacer()
                                
                                //remove/unfollow logic button
                                Button(action: {
                                    Task {
                                        await handleRemoveOrUnfollow(userId: userId)
                                    }
                                }){
                                    Text(selectedTab == .followers ? "Remove" : "Unfollow")
                                        .foregroundColor(.red)
                                }.buttonStyle(BorderlessButtonStyle())//doesn't extend button to full row
                            }
                        }
                    }.listRowBackground(Color.backgroundColor)
                    
                }
            }.scrollContentBackground(.hidden)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.textColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Socials")
                    .foregroundColor(Color.backgroundColor)
                    .bold()
            }
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        dismiss()
                    }){
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color.backgroundColor)
                            Text("Profile")
                                .foregroundColor(Color.backgroundColor)
                                .bold()
                        }
                    }
                }
        }
        .task { await loadUserProfiles() }
    }
    
    private func handleRemoveOrUnfollow(userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            if selectedTab == .followers {
                // Remove this user from followers (they unfollow us)
                // This means we unfollow them from their perspective
                try await repo.unfollowUser(currentUserId: userId, targetUserId: currentUserId)
                followers.removeAll { $0 == userId }
            } else {
                // Unfollow this user
                try await repo.unfollowUser(currentUserId: currentUserId, targetUserId: userId)
                following.removeAll { $0 == userId }
            }
        } catch {
            print("Error removing/unfollowing user: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func loadUserProfiles() async {
        let allIds = Set(followers + following)
        let missingIds = allIds.filter { usersById[$0] == nil }
        guard !missingIds.isEmpty else { return }
        
        await withTaskGroup(of: (String, UserPublic?).self) { group in
            for userId in missingIds {
                group.addTask {
                    do {
                        let user = try await repo.fetchUser(id: userId)
                        return (userId, user)
                    } catch {
                        print("Failed to fetch user \(userId): \(error.localizedDescription)")
                        return (userId, nil)
                    }
                }
            }
            
            for await (userId, user) in group {
                if let user {
                    usersById[userId] = user
                }
            }
        }
    }
    
    @ViewBuilder
    private func avatarView(for user: UserPublic?) -> some View {
        if let urlString = user?.profilePicture, let url = URL(string: urlString) {
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
                            .font(.caption).bold()
                            .foregroundColor(.secondary)
                    }
                @unknown default:
                    Circle().fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .foregroundColor(Color.accentColor)
                .font(.title2)
        }
    }
    
    private func initials(from user: UserPublic?) -> String {
        let f = user?.firstName.first.map { String($0) } ?? ""
        let l = user?.lastName.first.map { String($0) } ?? ""
        return (f + l).uppercased()
    }
}

