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
                            HStack{
                                NavigationLink(destination: PublicProfileView(userId: userId)) {
                                    HStack{
                                        //display user icon
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(Color.accentColor)
                                            .font(.title2)
                                
                                        //display user id
                                        Text("User")
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
}


